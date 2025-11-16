//
//  ReviewListViewModel.swift
//  koin
//
//  Created by 김나훈 on 8/13/24.
//

import Combine
import Foundation

final class ReviewListViewModel: ViewModelProtocol {

    private let fetchShopReviewListUseCase: FetchShopReviewListUseCase
    private let fetchMyReviewUseCase: FetchMyReviewUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private let deleteReviewUseCase: DeleteReviewUseCase
    private let getUserScreenTimeUseCase: GetUserScreenTimeUseCase


    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []

    private let shopId: Int
    private let shopName: String

    struct PaginationState {
        var currentPage: Int = 0
        var totalPage: Int = 0
        var isLoading: Bool = false
    }
    
    private(set) var paginationState = PaginationState()
    private var deleteTarget: (reviewId: Int, shopId: Int)?
    private var sorter: ReviewSortType = .latest
    private var isMineOnly: Bool = false

    var canFetchMore: Bool {
        paginationState.currentPage < paginationState.totalPage && !paginationState.isLoading
    }
    
    var deleteParameter: (Int, Int) {
        get { deleteTarget ?? (0, 0) }
        set { deleteTarget = (newValue.0, newValue.1) }
    }
    
    private enum LoginCheckContext {
        case writeReview
        case myReviewFilter
        case reportReview
    }
    
    private var loginCheckContext: LoginCheckContext = .writeReview

    // MARK: - Input/Output
    enum Input {
        case viewDidLoad
        case fetchNextPage
        case changeFilter(sorter: ReviewSortType?, isMine: Bool?)
        case checkLoginForWriteReview
        case checkLoginForMyReviewFilter
        case checkLoginForReportReview((Int, Int))
        case deleteReview(Int, Int)
        case logEvent(EventLabelType, EventParameter.EventCategory, Any)
        case logEventWithDuration(EventLabelType, EventParameter.EventCategory, Any, String? = nil, String? = nil, ScreenActionType? = nil, EventParameter.EventLabelNeededDuration? = nil)
        case getUserScreenAction(Date, ScreenActionType, EventParameter.EventLabelNeededDuration? = nil)


    }

    enum Output {
        case showWriteReviewLoginModal
        case showReportReviewLoginModal
        case showMyReviewFilterError
        case navigateToWriteReview
        case navigateToReportReview(Int, Int)
        case applyMyReviewFilter
        case deleteReview(Int, Int)
        case setReviewList(
            reviews: [Review],
            sortType: ReviewSortType,
            isMineOnly: Bool,
            currentPage: Int,
            totalPage: Int,
            shouldReset: Bool
        )
        case setStatistics(StatisticsDto)
        case updateLoadingState(Bool)
    }

    // MARK: - Initialize
    init(
        fetchShopReviewListUseCase: FetchShopReviewListUseCase,
        fetchMyReviewUseCase: FetchMyReviewUseCase,
        logAnalyticsEventUseCase: LogAnalyticsEventUseCase,
        deleteReviewUseCase: DeleteReviewUseCase,
        getUserScreenTimeUseCase: GetUserScreenTimeUseCase,
        shopId: Int,
        shopName: String
    ) {
        self.fetchShopReviewListUseCase = fetchShopReviewListUseCase
        self.fetchMyReviewUseCase = fetchMyReviewUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
        self.deleteReviewUseCase = deleteReviewUseCase
        self.getUserScreenTimeUseCase = getUserScreenTimeUseCase
        self.shopId = shopId
        self.shopName = shopName
    }
    
    // MARK: - Convenience Initialize
    convenience init(shopId: Int, shopName: String) {
        let shopRepository = DefaultShopRepository(service: DefaultShopService())
        self.init(
            fetchShopReviewListUseCase: DefaultFetchShopReviewListUseCase(
                shopRepository: shopRepository
            ),
            fetchMyReviewUseCase: DefaultFetchMyReviewUseCase(
                shopRepository: shopRepository
            ),
            logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(
                repository: GA4AnalyticsRepository(service: GA4AnalyticsService())
            ),
            deleteReviewUseCase: DefaultDeleteReviewUseCase(
                shopRepository: shopRepository
            ),
            getUserScreenTimeUseCase: DefaultGetUserScreenTimeUseCase(),
            shopId: shopId,
            shopName: shopName
        )
    }

    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .sink { [weak self] event in
                guard let self else { return }
                switch event {
                case .viewDidLoad:
                    self.fetchReviewList(page: 1, shouldReset: true)
                case .fetchNextPage:
                    guard self.canFetchMore else { return }
                    let nextPage = self.paginationState.currentPage + 1
                    self.fetchReviewList(page: nextPage, shouldReset: false)

                case let .changeFilter(sorter, isMine):
                    if let sorter = sorter {
                        self.sorter = sorter
                    }
                    if let isMine = isMine {
                        self.isMineOnly = isMine
                    }
                    self.fetchReviewList(page: 1, shouldReset: true)

                case .checkLoginForWriteReview:
                    self.loginCheckContext = .writeReview
                    self.checkLogin(parameter: nil)

                case .checkLoginForMyReviewFilter:
                    self.loginCheckContext = .myReviewFilter
                    self.checkLogin(parameter: nil)

                case let .checkLoginForReportReview(parameter):
                    self.loginCheckContext = .reportReview
                    self.checkLogin(parameter: parameter)
                    
                case let .deleteReview(reviewId, shopId):
                    self.deleteReview(reviewId: reviewId, shopId: shopId)

                case let .logEvent(label, category, value):
                    self.logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
                    
                case let .getUserScreenAction(time, screenActionType, eventLabelNeededDuration):
                    self.getScreenAction(time: time, screenActionType: screenActionType, eventLabelNeededDuration: eventLabelNeededDuration)
                    
                case let .logEventWithDuration(label, category, value, previousPage, currentPage, durationType, eventLabelNeededDuration):
                    self.makeLogAnalyticsEvent(label: label, category: category, value: value, previousPage: previousPage, currentPage: currentPage, screenActionType: durationType, eventLabelNeededDuration: eventLabelNeededDuration)
                }
            }
            .store(in: &subscriptions)

        return outputSubject.eraseToAnyPublisher()
    }
}

extension ReviewListViewModel {

    func getShopName() -> String {
        return shopName
    }
    
    func getShopId() -> Int {
        return shopId
    }
    
    func getCurrentSortType() -> ReviewSortType {
        return sorter
    }
}

extension ReviewListViewModel {

    private func fetchReviewList(page: Int, shouldReset: Bool) {
        guard !paginationState.isLoading else {
            return
        }
        
        if !shouldReset && paginationState.totalPage > 0 && page > paginationState.totalPage {
            return
        }
        
        paginationState.isLoading = true
        outputSubject.send(.updateLoadingState(true))

        if isMineOnly {
            fetchMyReviewList(page: page, shouldReset: shouldReset)
        } else {
            fetchAllReviewList(page: page, shouldReset: shouldReset)
        }
    }
    
    private func fetchAllReviewList(page: Int, shouldReset: Bool) {
        let requestModel = FetchShopReviewRequest(
            shopId: shopId,
            page: page,
            sorter: sorter
        )

        fetchShopReviewListUseCase.execute(requestModel: requestModel)
            .sink { [weak self] completion in
                guard let self else { return }
                self.paginationState.isLoading = false
                self.outputSubject.send(.updateLoadingState(false))
                
                if case let .failure(error) = completion {
                    print("❌ fetchAllReviewList error: \(error)")
                }
            } receiveValue: { [weak self] shopReview in
                guard let self else { return }
                
                self.paginationState.currentPage = shopReview.currentPage
                self.paginationState.totalPage = shopReview.totalPage

                if shouldReset {
                    self.outputSubject.send(.setStatistics(shopReview.statistics))
                }
                
                self.outputSubject.send(.setReviewList(
                    reviews: shopReview.reviews,
                    sortType: self.sorter,
                    isMineOnly: self.isMineOnly,
                    currentPage: shopReview.currentPage,
                    totalPage: shopReview.totalPage,
                    shouldReset: shouldReset
                ))
            }
            .store(in: &subscriptions)
    }
    
    private func fetchMyReviewList(page: Int, shouldReset: Bool) {
        let requestModel = FetchMyReviewRequest(sorter: sorter)
        
        fetchMyReviewUseCase.execute(requestModel: requestModel, shopId: shopId)
            .sink { [weak self] completion in
                guard let self else { return }
                self.paginationState.isLoading = false
                self.outputSubject.send(.updateLoadingState(false))
                
                if case let .failure(error) = completion {
                    print("❌ fetchMyReviewList error: \(error)")
                }
            } receiveValue: { [weak self] reviews in
                guard let self else { return }
                
                self.paginationState.currentPage = 1
                self.paginationState.totalPage = 1

                self.outputSubject.send(.setReviewList(
                    reviews: reviews,
                    sortType: self.sorter,
                    isMineOnly: self.isMineOnly,
                    currentPage: 1,
                    totalPage: 1,
                    shouldReset: shouldReset
                ))
            }
            .store(in: &subscriptions)
    }

    private func checkLogin(parameter: (Int, Int)?) {
        switch UserDataManager.shared.userId.isEmpty {
        case true:
            switch self.loginCheckContext {
            case .writeReview:
                self.outputSubject.send(.showWriteReviewLoginModal)
                
            case .myReviewFilter:
                isMineOnly=true
                self.paginationState.currentPage = 1
                self.paginationState.totalPage = 1

                self.outputSubject.send(.setReviewList(
                    reviews: [],
                    sortType: self.sorter,
                    isMineOnly: self.isMineOnly,
                    currentPage: 1,
                    totalPage: 1,
                    shouldReset: true
                ))
                self.outputSubject.send(.showMyReviewFilterError)
                
            case .reportReview:
                self.outputSubject.send(.showReportReviewLoginModal)
            }
        case false:
            switch self.loginCheckContext {
            case .writeReview:
                self.outputSubject.send(.navigateToWriteReview)
                
            case .myReviewFilter:
                self.outputSubject.send(.applyMyReviewFilter)
                
            case .reportReview:
                if let parameter {
                    self.outputSubject.send(.navigateToReportReview(parameter.0, parameter.1))
                }
            }
        }
    }
    
    private func deleteReview(reviewId: Int, shopId: Int) {
        deleteReviewUseCase.execute(reviewId: reviewId, shopId: shopId)
            .sink { [weak self] completion in
                guard let self else { return }
                if case let .failure(error) = completion {
                    print("❌ deleteReview error: \(error)")
                }
            } receiveValue: { [weak self] _ in
                guard let self else { return }
                self.outputSubject.send(.deleteReview(reviewId, shopId))
            }
            .store(in: &subscriptions)
    }

    private func makeLogAnalyticsEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any, previousPage: String? = nil, currentPage: String? = nil, screenActionType: ScreenActionType? = nil, eventLabelNeededDuration: EventParameter.EventLabelNeededDuration? = nil) {
        if eventLabelNeededDuration != nil {
            var durationTime = getUserScreenTimeUseCase.returnUserScreenTime(isEventTime: false)
            
            if eventLabelNeededDuration == .shopDetailViewReviewBack {
                durationTime = getUserScreenTimeUseCase.returnUserScreenTime(isEventTime: true)
            }
            
            logAnalyticsEventUseCase.executeWithDuration(label: label, category: category, value: value, previousPage: previousPage, currentPage: currentPage, durationTime: "\(durationTime)")
        }
        else {
            logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
        }
    }
    
    private func getScreenAction(time: Date, screenActionType: ScreenActionType, eventLabelNeededDuration: EventParameter.EventLabelNeededDuration? = nil) {
        getUserScreenTimeUseCase.getUserScreenAction(time: time, screenActionType: screenActionType, screenEventLabel: eventLabelNeededDuration)
    }
    

}

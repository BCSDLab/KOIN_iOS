//
//  ReviewListViewModel.swift
//  koin
//
//  Created by 김나훈 on 8/13/24.
//

import Combine

final class ReviewListViewModel: ViewModelProtocol {

    private let fetchShopReviewListUseCase: FetchShopReviewListUseCase
    private let fetchMyReviewUseCase: FetchMyReviewUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private let fetchUserDataUseCase: FetchUserDataUseCase
    private let deleteReviewUseCase: DeleteReviewUseCase

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
        fetchUserDataUseCase: FetchUserDataUseCase,
        deleteReviewUseCase: DeleteReviewUseCase,
        shopId: Int,
        shopName: String
    ) {
        self.fetchShopReviewListUseCase = fetchShopReviewListUseCase
        self.fetchMyReviewUseCase = fetchMyReviewUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
        self.fetchUserDataUseCase = fetchUserDataUseCase
        self.deleteReviewUseCase = deleteReviewUseCase
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
            fetchUserDataUseCase: DefaultFetchUserDataUseCase(
                userRepository: DefaultUserRepository(service: DefaultUserService())
            ),
            deleteReviewUseCase: DefaultDeleteReviewUseCase(
                shopRepository: shopRepository
            ),
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
                    self.logAnalyticsEvent(label: label, category: category, value: value)
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
        fetchUserDataUseCase.execute()
            .sink { [weak self] completion in
                guard let self else { return }
                if case .failure = completion {
                    switch self.loginCheckContext {
                    case .writeReview:
                        self.outputSubject.send(.showWriteReviewLoginModal)
                        
                    case .myReviewFilter:
                        self.outputSubject.send(.showMyReviewFilterError)
                        
                    case .reportReview:
                        self.outputSubject.send(.showReportReviewLoginModal)
                    }
                }
            } receiveValue: { [weak self] _ in
                guard let self else { return }
                
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
            .store(in: &subscriptions)
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

    private func logAnalyticsEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any) {
        logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
    }
}

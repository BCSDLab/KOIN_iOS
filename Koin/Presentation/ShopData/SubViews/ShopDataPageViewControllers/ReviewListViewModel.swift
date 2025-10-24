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

    // MARK: - Input/Output
    enum Input {
        case viewDidLoad
        case fetchNextPage
        case changeFilter(sorter: ReviewSortType?, isMine: Bool?)
        case checkLogin((Int, Int)?)
        case logEvent(EventLabelType, EventParameter.EventCategory, Any)
    }

    enum Output {
        case updateLoginStatus(Bool, (Int, Int)?)
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
        shopId: Int,
        shopName: String
    ) {
        self.fetchShopReviewListUseCase = fetchShopReviewListUseCase
        self.fetchMyReviewUseCase = fetchMyReviewUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
        self.fetchUserDataUseCase = fetchUserDataUseCase
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

                case let .checkLogin(parameter):
                    self.checkLogin(parameter: parameter)

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
                if case .failure = completion {
                    self?.outputSubject.send(.updateLoginStatus(false, parameter))
                }
            } receiveValue: { [weak self] _ in
                self?.outputSubject.send(.updateLoginStatus(true, parameter))
            }
            .store(in: &subscriptions)
    }

    private func logAnalyticsEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any) {
        logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
    }
}

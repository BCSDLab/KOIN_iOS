//
//  ReviewListViewModel.swift
//  koin
//
//  Created by 김나훈 on 8/13/24.
//

import Combine

final class ReviewListViewModel: ViewModelProtocol {

    // MARK: - Dependencies
    private let fetchShopReviewListUseCase: FetchShopReviewListUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private let fetchUserDataUseCase: FetchUserDataUseCase

    // MARK: - Streams
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []

    // MARK: - Immutable State
    private let shopId: Int
    private let shopName: String

    // MARK: - Mutable State
    private struct PaginationState {
        var currentPage: Int = 0
        var totalPage: Int = 0
        var isLoading: Bool = false
    }
    
    private var paginationState = PaginationState()
    private var deleteTarget: (reviewId: Int, shopId: Int)?
    private var sorter: ReviewSortType = .latest
    private var isMineOnly: Bool = false

    // MARK: - Computed Properties
    var canFetchMore: Bool {
        paginationState.currentPage < paginationState.totalPage && !paginationState.isLoading
    }
    
    var deleteParameter: (Int, Int) {
        get { deleteTarget ?? (0, 0) }
        set { deleteTarget = (newValue.0, newValue.1) }
    }

    // MARK: - IO
    enum Input {
        case viewDidLoad
        case fetchNext(page: Int)
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

    // MARK: - Init
    init(
        fetchShopReviewListUseCase: FetchShopReviewListUseCase,
        logAnalyticsEventUseCase: LogAnalyticsEventUseCase,
        fetchUserDataUseCase: FetchUserDataUseCase,
        shopId: Int,
        shopName: String
    ) {
        self.fetchShopReviewListUseCase = fetchShopReviewListUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
        self.fetchUserDataUseCase = fetchUserDataUseCase
        self.shopId = shopId
        self.shopName = shopName
    }
    
    // MARK: - Convenience Init
    convenience init(shopId: Int, shopName: String) {
        let shopRepository = DefaultShopRepository(service: DefaultShopService())
        self.init(
            fetchShopReviewListUseCase: DefaultFetchShopReviewListUseCase(
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
                    self.request(page: 1, shouldReset: true)

                case let .fetchNext(page):
                    self.request(page: page, shouldReset: false)

                case let .changeFilter(sorter, isMine):
                    if let sorter = sorter {
                        self.sorter = sorter
                    }
                    if let isMine = isMine {
                        self.isMineOnly = isMine
                    }
                    self.request(page: 1, shouldReset: true)

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

// MARK: - Public Methods
extension ReviewListViewModel {
    
    func getShopName() -> String {
        return shopName
    }
    
    func getShopId() -> Int {
        return shopId
    }
}

// MARK: - Private Methods
private extension ReviewListViewModel {

    func request(page: Int, shouldReset: Bool) {
        guard !paginationState.isLoading else { return }
        
        paginationState.isLoading = true
        outputSubject.send(.updateLoadingState(true))

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
                    #if DEBUG
                    print("❌ fetchReviewList error: \(error)")
                    #endif
                }
            } receiveValue: { [weak self] shopReview in
                guard let self else { return }
                
                self.paginationState.currentPage = shopReview.currentPage
                self.paginationState.totalPage = shopReview.totalPage

                self.outputSubject.send(
                    .setReviewList(
                        reviews: shopReview.reviews,
                        sortType: self.sorter,
                        isMineOnly: self.isMineOnly,
                        currentPage: shopReview.currentPage,
                        totalPage: shopReview.totalPage,
                        shouldReset: shouldReset
                    )
                )
            }
            .store(in: &subscriptions)
    }

    func checkLogin(parameter: (Int, Int)?) {
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

    func logAnalyticsEvent(
        label: EventLabelType,
        category: EventParameter.EventCategory,
        value: Any
    ) {
        logAnalyticsEventUseCase.execute(
            label: label,
            category: category,
            value: value
        )
    }
}

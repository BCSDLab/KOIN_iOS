//
//  ShopDataViewModel.swift
//  koin
//
//  Created by 김나훈 on 3/13/24.
//

import Combine

final class ShopDataViewModel: ViewModelProtocol {
        
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let shopId: Int
    private let fetchShopDataUseCase: FetchShopDataUseCase
    private let fetchShopMenuListUseCase: FetchShopMenuListUseCase
    private let fetchShopEventListUseCase: FetchShopEventListUseCase
    private let fetchShopReviewListUseCase: FetchShopReviewListUseCase
    private let fetchMyReviewUseCase: FetchMyReviewUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private let deleteReviewUseCase: DeleteReviewUseCase
    private(set) var eventItem: [ShopEvent] = []
    private(set) var menuItem: [MenuCategory] = []
    private var fetchStandard: (ReviewSortType, Bool) = (.latest, false) {
        didSet {
            if fetchStandard.1 { fetchMyReviewList() }
            else { fetchShopReviewList() }
        }
    }
    
    enum Input {
        case viewDidLoad
        case fetchShopEventList
        case fetchShopMenuList
        case fetchShopReviewList
        case deleteReview(Int, Int)
        case logEvent(EventLabelType, EventParameter.EventCategory, Any)
        case changeFetchStandard(ReviewSortType?, Bool?)
    }
    enum Output {
        case showShopData(ShopData)
        case showShopMenuList([MenuCategory])
        case showShopEventList([ShopEvent])
        case showShopReviewList([Review])
        case showShopReviewStatistics(StatisticsDTO)
    }
    
    init(fetchShopDataUseCase: FetchShopDataUseCase, fetchShopMenuListUseCase: FetchShopMenuListUseCase, fetchShopEventListUseCase: FetchShopEventListUseCase, fetchShopReviewListUseCase: FetchShopReviewListUseCase, fetchMyReviewUseCase: FetchMyReviewUseCase, deleteReviewUseCase: DeleteReviewUseCase, logAnalyticsEventUseCase: LogAnalyticsEventUseCase, shopId: Int) {
        self.fetchShopDataUseCase = fetchShopDataUseCase
        self.fetchShopMenuListUseCase = fetchShopMenuListUseCase
        self.fetchShopEventListUseCase = fetchShopEventListUseCase
        self.fetchShopReviewListUseCase = fetchShopReviewListUseCase
        self.fetchMyReviewUseCase = fetchMyReviewUseCase
        self.deleteReviewUseCase = deleteReviewUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
        self.shopId = shopId
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case .viewDidLoad:
                self?.fetchShopData()
                self?.fetchShopMenuList()
            case let .logEvent(label, category, value):
                self?.makeLogAnalyticsEvent(label: label, category: category, value: value)
            case .fetchShopEventList:
                self?.fetchShopEventList()
            case .fetchShopMenuList:
                self?.fetchShopMenuList()
            case .fetchShopReviewList:
                self?.fetchShopReviewList()
            case let .changeFetchStandard(type, isMine):
                self?.changeFetchStandard(type, isMine)
            case let .deleteReview(reviewId, shopId):
                self?.deleteReview(reviewId, shopId)
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension ShopDataViewModel {
    
    private func deleteReview(_ reviewId: Int, _ shopId: Int) {
        deleteReviewUseCase.execute(reviewId: reviewId, shopId: shopId).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            print(response)
        }.store(in: &subscriptions)

    }
    
    private func changeFetchStandard(_ type: ReviewSortType?, _ isMine: Bool?) {
        if let type = type {
            fetchStandard.0 = type
        }
        if let isMine = isMine {
            fetchStandard.1 = isMine
        }
    }
    
    private func fetchMyReviewList() {
        fetchMyReviewUseCase.execute(requestModel: FetchMyReviewRequest(sorter: fetchStandard.0), shopId: shopId).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.showShopReviewList(response))
        }.store(in: &subscriptions)
    }
    
    private func fetchShopReviewList() {
        fetchShopReviewListUseCase.execute(requestModel: FetchShopReviewRequest(shopId: shopId, page: 1, sorter: fetchStandard.0)).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.showShopReviewList(response.review))
            self?.outputSubject.send(.showShopReviewStatistics(response.reviewStatistics))
        }.store(in: &subscriptions)
    }
    
    private func fetchShopData() {
        fetchShopDataUseCase.execute(shopId: shopId).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.showShopData(response))
        }.store(in: &subscriptions)
    }
    
    private func fetchShopMenuList() {
        fetchShopMenuListUseCase.execute(shopId: shopId).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            self?.menuItem = response
            self?.outputSubject.send(.showShopMenuList(response))
        }.store(in: &subscriptions)
    }
    
    private func fetchShopEventList() {
        fetchShopEventListUseCase.execute(shopId: shopId).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            self?.eventItem = response
            self?.outputSubject.send(.showShopEventList(response))
        }.store(in: &subscriptions)
    }
    
    private func makeLogAnalyticsEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any) {
        logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
    }
}

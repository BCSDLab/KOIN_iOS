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
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private (set) var eventItem: [ShopEvent] = []
    private (set) var menuItem: [MenuCategory] = []
    
    enum Input {
        case viewDidLoad
        case fetchShopEventList
        case fetchShopMenuList
        case fetchShopReviewList
        case logEvent(EventLabelType, EventParameter.EventCategory, Any)
    }
    enum Output {
        case showShopData(ShopData)
        case showShopMenuList([MenuCategory])
        case showShopEventList([ShopEvent])
        case showShopReviewList(ShopReview)
    }
    
    init(fetchShopDataUseCase: FetchShopDataUseCase, fetchShopMenuListUseCase: FetchShopMenuListUseCase, fetchShopEventListUseCase: FetchShopEventListUseCase, fetchShopReviewListUseCase: FetchShopReviewListUseCase, logAnalyticsEventUseCase: LogAnalyticsEventUseCase, shopId: Int) {
        self.fetchShopDataUseCase = fetchShopDataUseCase
        self.fetchShopMenuListUseCase = fetchShopMenuListUseCase
        self.fetchShopEventListUseCase = fetchShopEventListUseCase
        self.fetchShopReviewListUseCase = fetchShopReviewListUseCase
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
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension ShopDataViewModel {
    
    private func fetchShopReviewList() {
        fetchShopReviewListUseCase.execute(requestModel: FetchShopReviewRequest(shopId: shopId, page: 1, sorter: .latest)).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.showShopReviewList(response))
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

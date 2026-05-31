//
//  ShopBenefitViewModel.swift
//  koin
//
//  Created by 홍기정 on 5/19/26.
//

import Foundation
import Combine

final class ShopBenefitViewModel: ViewModelProtocol {
    
    enum Input {
        case fetchEvents
        case logEvent(EventLabelType, EventParameter.EventCategory, Any)
    }
    enum Output {
        case updateEvents(events: [ShopEvent])
    }
    
    // MARK: - Properties
    private let fetchShopEventListUseCase: FetchShopEventListUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    
    private let outputPublisher = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
    private let shopId: Int
    let shopName: String
    
    // MARK: - Initializer
    init(
        fetchShopEventListUseCase: FetchShopEventListUseCase,
        logAnalyticsEventUseCase: LogAnalyticsEventUseCase,
        shopId: Int,
        shopName: String
    ) {
        self.fetchShopEventListUseCase = fetchShopEventListUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
        self.shopId = shopId
        self.shopName = shopName
    }
    
    // MARK: - Public
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            guard let self else { return }
            switch input {
            case .fetchEvents:
                fetchEvents()
            case let .logEvent(label, category, value):
                makeLogAnalyticsEvent(label: label, category: category, value: value)
            }
        }.store(in: &subscriptions)
        return outputPublisher.eraseToAnyPublisher()
    }
}

extension ShopBenefitViewModel {
    
    func fetchEvents() {
        fetchShopEventListUseCase.execute(shopId: shopId).sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] events in
                self?.outputPublisher.send(.updateEvents(events: events))
            }
        ).store(in: &subscriptions)
    }

    private func makeLogAnalyticsEvent(
        label: EventLabelType,
        category: EventParameter.EventCategory,
        value: Any
    ) {
        logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
    }
}

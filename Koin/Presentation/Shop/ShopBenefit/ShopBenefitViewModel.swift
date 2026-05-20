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
    }
    enum Output {
        case updateEvents(events: [ShopEvent])
    }
    
    // MARK: - Properties
    private let fetchShopEventListUseCase: FetchShopEventListUseCase
    
    private let outputPublisher = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
    private let shopId: Int
    
    // MARK: - Initializer
    init(
        fetchShopEventListUseCase: FetchShopEventListUseCase,
        shopId: Int
    ) {
        self.fetchShopEventListUseCase = fetchShopEventListUseCase
        self.shopId = shopId
    }
    
    // MARK: - Public
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            guard let self else { return }
            switch input {
            case .fetchEvents:
                fetchEvents()
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
}

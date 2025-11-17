//
//  FetchOrderEventShopUseCase.swift
//  koin
//
//  Created by 이은지 on 7/31/25.
//

import Combine

protocol FetchOrderEventShopUseCase {
    func execute() -> AnyPublisher<[OrderShopEvent], Error>
}

final class DefaultFetchOrderEventShopUseCase: FetchOrderEventShopUseCase {
    private let orderShopRepository: OrderShopRepository

    init(orderShopRepository: OrderShopRepository) {
        self.orderShopRepository = orderShopRepository
    }

    func execute() -> AnyPublisher<[OrderShopEvent], Error> {
        return orderShopRepository.fetchOrderEventShop()
            .eraseToAnyPublisher()
    }
}

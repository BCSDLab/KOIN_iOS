//  FetchOrderMenuUseCase.swift
//  koin
//
//  Created by 김성민 on 10/12/25.
//

import Combine

protocol FetchOrderMenuUseCase {
    func execute(orderableShopId: Int,
                 orderableShopMenuId: Int) -> AnyPublisher<OrderMenu, Error>
}

final class DefaultFetchOrderMenuUseCase: FetchOrderMenuUseCase {
    private let repository: OrderShopRepository
    
    init(repository: OrderShopRepository) {
        self.repository = repository
    }

    func execute(orderableShopId: Int,
                 orderableShopMenuId: Int) -> AnyPublisher<OrderMenu, Error> {
        repository.fetchOrderMenu(orderableShopId: orderableShopId,
                                  orderableShopMenuId: orderableShopMenuId)
            .eraseToAnyPublisher()
    }
}


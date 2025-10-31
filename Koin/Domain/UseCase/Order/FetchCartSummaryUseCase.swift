//
//  FetchCartSummaryUseCase.swift
//  koin
//
//  Created by 홍기정 on 9/15/25.
//

import Combine

protocol FetchCartSummaryUseCase {
    func execute(orderableShopId: Int) -> AnyPublisher<CartSummary, Error>
}

final class DefaultFetchCartSummaryUseCase: FetchCartSummaryUseCase {
    
    private let repository: OrderShopRepository
    
    init(repository: OrderShopRepository) {
        self.repository = repository
    }
    
    func execute(orderableShopId: Int) -> AnyPublisher<CartSummary, Error> {
        repository.fetchCartSummary(orderableShopId: orderableShopId)
            .eraseToAnyPublisher()
    }
}

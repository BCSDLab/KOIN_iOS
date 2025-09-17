//
//  FetchShopSummaryUseCase.swift
//  koin
//
//  Created by 홍기정 on 9/14/25.
//

import Combine

protocol FetchShopSummaryUseCase {
    func execute(id: Int) -> AnyPublisher<OrderShopSummary, Error>
}

final class DefaultFetchShopSummaryUseCase: FetchShopSummaryUseCase {
    let repository: ShopRepository
        
    init(repository: ShopRepository) {
        self.repository = repository
    }
    
    func execute(id: Int) -> AnyPublisher<OrderShopSummary, Error> {
        return repository.fetchShopSummary(id: id)
            .map { shopSummary in
                return OrderShopSummary(from: shopSummary)
            }
            .eraseToAnyPublisher()
    }
}

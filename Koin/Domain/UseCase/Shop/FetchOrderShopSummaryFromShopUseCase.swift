//
//  FetchShopSummaryUseCase.swift
//  koin
//
//  Created by 홍기정 on 9/14/25.
//

import Combine

protocol FetchOrderShopSummaryFromShopUseCase {
    func execute(id: Int) -> AnyPublisher<OrderShopSummary, Error>
}

final class DefaultFetchOrderShopSummaryFromShopUseCase: FetchOrderShopSummaryFromShopUseCase {
    let repository: ShopRepository
        
    init(repository: ShopRepository) {
        self.repository = repository
    }
    
    func execute(id: Int) -> AnyPublisher<OrderShopSummary, Error> {
        return repository.fetchShopSummary(id: id)
            .map { shopSummaryDto in
                return OrderShopSummary(from: shopSummaryDto, shopId: id)
            }
            .eraseToAnyPublisher()
    }
}

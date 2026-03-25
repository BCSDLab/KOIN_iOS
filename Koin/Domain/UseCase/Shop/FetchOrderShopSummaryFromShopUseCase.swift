//
//  FetchShopSummaryUseCase.swift
//  koin
//
//  Created by 홍기정 on 9/14/25.
//

import Combine

protocol FetchOrderShopSummaryFromShopUseCase {
    func execute(id: Int) -> AnyPublisher<OrderShopSummary, ErrorResponse>
}

final class DefaultFetchOrderShopSummaryFromShopUseCase: FetchOrderShopSummaryFromShopUseCase {
    
    private let repository: ShopRepository
        
    init(repository: ShopRepository) {
        self.repository = repository
    }
    
    func execute(id: Int) -> AnyPublisher<OrderShopSummary, ErrorResponse> {
        return repository.fetchShopSummary(id: id)
            .map { shopSummaryDto in
                return OrderShopSummary(from: shopSummaryDto, shopId: id)
            }
            .eraseToAnyPublisher()
    }
}

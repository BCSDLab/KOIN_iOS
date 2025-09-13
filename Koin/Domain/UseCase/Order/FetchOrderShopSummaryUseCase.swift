//
//  FetchOrderShopSummaryUseCase.swift
//  koin
//
//  Created by 홍기정 on 9/12/25.
//

import Foundation
import Combine

protocol FetchOrderShopSummaryUseCase {
    func execute(shopId: Int) -> AnyPublisher<OrderShopSummary, Error>
}

final class DefaultFetchOrderShopSummaryUseCase: FetchOrderShopSummaryUseCase {
    let repository: OrderShopRepository
    
    init(repository: OrderShopRepository) {
        self.repository = repository
    }
    
    func execute(shopId: Int) -> AnyPublisher<OrderShopSummary, Error> {
        return repository.fetchOrderShopSummary(shopId: shopId)
            .eraseToAnyPublisher()
    }
}

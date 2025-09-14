//
//  FetchOrderShopSummaryUseCase.swift
//  koin
//
//  Created by 홍기정 on 9/12/25.
//

import Foundation
import Combine

protocol FetchOrderShopSummaryUseCase {
    func execute(orderableShopId: Int) -> AnyPublisher<OrderShopSummary, Error>
}

final class DefaultFetchOrderShopSummaryUseCase: FetchOrderShopSummaryUseCase {
    let repository: OrderShopRepository
    
    init(repository: OrderShopRepository) {
        self.repository = repository
    }
    
    func execute(orderableShopId: Int) -> AnyPublisher<OrderShopSummary, Error> {
        return repository.fetchOrderShopSummary(orderableShopId: orderableShopId)
            .eraseToAnyPublisher()
    }
}

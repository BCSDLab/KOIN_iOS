//
//  FetchOrderShopDetailUseCase.swift
//  koin
//
//  Created by 홍기정 on 10/31/25.
//

import Foundation
import Combine

protocol FetchOrderShopDetailUseCase {
    func execute(orderableShopId: Int) -> AnyPublisher<OrderShopDetail, Error>
}

final class DefaultFetchOrderShopDetailUseCase: FetchOrderShopDetailUseCase {
    
    private let repository: OrderShopRepository
    
    init(repository: OrderShopRepository) {
        self.repository = repository
    }
    
    func execute(orderableShopId: Int) -> AnyPublisher<OrderShopDetail, Error> {
        repository.fetchOrderShopDetail(orderableShopId: orderableShopId)
            .eraseToAnyPublisher()
    }
    
}

//
//  FetchOrderShopMenusUseCase.swift
//  koin
//
//  Created by 홍기정 on 9/12/25.
//

import Foundation
import Combine

protocol FetchOrderShopMenusUseCase {
    func execute(orderableShopId: Int) -> AnyPublisher<[OrderShopMenus], Error>
}

final class DefaultFetchOrderShopMenusUseCase: FetchOrderShopMenusUseCase {
    private let repository: OrderShopRepository
    
    init(repository: OrderShopRepository) {
        self.repository = repository
    }
    
    func execute(orderableShopId: Int) -> AnyPublisher<[OrderShopMenus], Error> {
        return repository.fetchOrderShopMenus(orderableShopId: orderableShopId)
            .eraseToAnyPublisher()
    }
}

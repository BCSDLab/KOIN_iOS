//
//  FetchOrderShopMenusGroupsUseCase.swift
//  koin
//
//  Created by 홍기정 on 9/12/25.
//

import Foundation
import Combine

protocol FetchOrderShopMenusGroupsUseCase {
    func execute(shopId: Int) -> AnyPublisher<OrderShopMenusGroups, Error>
}

final class DefaultFetchOrderShopMenusGroupsUseCase: FetchOrderShopMenusGroupsUseCase {
    private let repository: OrderShopRepository
    
    init(repository: OrderShopRepository) {
        self.repository = repository
    }
    
    func execute(shopId: Int) -> AnyPublisher<OrderShopMenusGroups, Error> {
        return repository.fetchOrderShopMenusGroups(shopId: shopId)
            .eraseToAnyPublisher()
    }
}

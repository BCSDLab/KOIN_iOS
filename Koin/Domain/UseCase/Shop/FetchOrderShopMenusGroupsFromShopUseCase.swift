//
//  FetchShopMenusCategoryListUseCase.swift
//  koin
//
//  Created by 홍기정 on 9/15/25.
//

import Combine

protocol FetchOrderShopMenusGroupsFromShopUseCase {
    func execute(shopId: Int) -> AnyPublisher<OrderShopMenusGroups, Error>
}

final class DefaultFetchOrderShopMenusGroupsFromShopUseCase: FetchOrderShopMenusGroupsFromShopUseCase {
    
    private let repository: ShopRepository
    
    init(repository: ShopRepository) {
        self.repository = repository
    }
    
    func execute(shopId: Int) -> AnyPublisher<OrderShopMenusGroups, any Error> {
        repository.fetchShopMenusCategoryList(shopId: shopId)
            .map { shopMenusCategoryDto in
                OrderShopMenusGroups(from: shopMenusCategoryDto)
            }
            .eraseToAnyPublisher()
    }
    
    
}

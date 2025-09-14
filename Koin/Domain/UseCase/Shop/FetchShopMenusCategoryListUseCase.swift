//
//  FetchShopMenusCategoryListUseCase.swift
//  koin
//
//  Created by 홍기정 on 9/15/25.
//

import Combine

protocol FetchShopMenusCategoryListUseCase {
    func execute(shopId: Int) -> AnyPublisher<OrderShopMenusGroups, Error>
}

class DefaultFetchShopmenusCategoryListUseCase: FetchShopMenusCategoryListUseCase {
    
    let repository: ShopRepository
    
    init(repository: ShopRepository) {
        self.repository = repository
    }
    
    func execute(shopId: Int) -> AnyPublisher<OrderShopMenusGroups, any Error> {
        repository.fetchShopMenusCategoryList(shopId: shopId)
            .map { shopMenusCategoryDTO in
                OrderShopMenusGroups(from: shopMenusCategoryDTO)
            }
            .eraseToAnyPublisher()
    }
    
    
}

//
//  FetchShopMenuListUseCase.swift
//  koin
//
//  Created by 김나훈 on 6/11/24.
//

import Combine

protocol FetchOrderShopMenusFromShopUseCase {
    func execute(shopId: Int) -> AnyPublisher<[OrderShopMenus], Error>
}

final class DefaultFetchOrderShopMenusFromShopUseCase: FetchOrderShopMenusFromShopUseCase {
    
    private let shopRepository: ShopRepository
    
    init(shopRepository: ShopRepository) {
        self.shopRepository = shopRepository
    }
    
    func execute(shopId: Int) -> AnyPublisher<[OrderShopMenus], Error> {
        return shopRepository.fetchShopMenuList(requestModel: FetchShopDataRequest(shopId: shopId)).map { menuDTO in
            let menuCategories = menuDTO.menuCategories ?? [] 
            return menuCategories.map {
                OrderShopMenus(from: $0)
            }
        }
        .eraseToAnyPublisher()
    }
}

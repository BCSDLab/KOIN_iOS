//
//  FetchOrderShopMenusAndGroupsFromShopUseCase.swift
//  koin
//
//  Created by 홍기정 on 11/7/25.
//

import Combine

protocol FetchOrderShopMenusAndGroupsFromShopUseCase {
    func execute(shopId: Int) -> AnyPublisher<(OrderShopMenusGroups, [OrderShopMenus]), Error>
}

final class DefaultFetchOrderShopMenusAndGroupsFromShopUseCase: FetchOrderShopMenusAndGroupsFromShopUseCase {
    
    private let shopRepository: ShopRepository
    
    init(shopRepository: ShopRepository) {
        self.shopRepository = shopRepository
    }
    
    func execute(shopId: Int) -> AnyPublisher<(OrderShopMenusGroups, [OrderShopMenus]), Error> {
        return shopRepository.fetchShopMenuList(requestModel: FetchShopDataRequest(shopId: shopId)).map { menuDto in
            let orderShopMenus: [OrderShopMenus] = (menuDto.menuCategories ?? []).map {
                OrderShopMenus(from: $0)
            }
            let menuGroup: [MenuGroup] = (menuDto.menuCategories ?? []).map {
                return MenuGroup(name: $0.name)
            }
            let orderShopMenuGroups = OrderShopMenusGroups(menuGroups: menuGroup)
            
            return (orderShopMenuGroups, orderShopMenus)
        }
        .eraseToAnyPublisher()
    }
}

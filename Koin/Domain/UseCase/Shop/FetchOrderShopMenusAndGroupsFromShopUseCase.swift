//
//  FetchOrderShopMenusAndGroupsFromShopUseCase.swift
//  koin
//
//  Created by 홍기정 on 11/7/25.
//

import Combine

protocol FetchOrderShopMenusAndGroupsFromShopUseCase {
    func execute(shopId: Int) -> AnyPublisher<(OrderShopMenusGroups, [ShopMenuGroup]), ErrorResponse>
}

final class DefaultFetchOrderShopMenusAndGroupsFromShopUseCase: FetchOrderShopMenusAndGroupsFromShopUseCase {
    
    private let shopRepository: ShopRepository
    
    init(shopRepository: ShopRepository) {
        self.shopRepository = shopRepository
    }
    
    func execute(shopId: Int) -> AnyPublisher<(OrderShopMenusGroups, [ShopMenuGroup]), ErrorResponse> {
        return shopRepository.fetchShopMenuList(requestModel: FetchShopDataRequest(shopId: shopId)).map { menuDto in
            let orderShopMenus: [ShopMenuGroup] = (menuDto.menuCategories ?? []).map {
                ShopMenuGroup(from: $0)
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

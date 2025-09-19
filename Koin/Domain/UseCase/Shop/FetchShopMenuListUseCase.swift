//
//  FetchShopMenuListUseCase.swift
//  koin
//
//  Created by 김나훈 on 6/11/24.
//

import Combine

protocol FetchShopMenuListUseCase {
    func execute(shopId: Int) -> AnyPublisher<[MenuCategory], Error>
}

final class DefaultFetchShopMenuListUseCase: FetchShopMenuListUseCase {
    
    private let shopRepository: ShopRepository
    
    init(shopRepository: ShopRepository) {
        self.shopRepository = shopRepository
    }
    
    func execute(shopId: Int) -> AnyPublisher<[MenuCategory], Error> {
        return shopRepository.fetchShopMenuList(requestModel: FetchShopDataRequest(shopId: shopId)).map { menuDTO in
            menuDTO.menuCategories ?? []
        }.eraseToAnyPublisher()
    }
}

//
//  FetchShopCategoryListUseCase.swift
//  koin
//
//  Created by 김나훈 on 5/22/24.
//

import Combine

protocol FetchShopCategoryListUseCase {
    func execute() -> AnyPublisher<ShopCategoryDTO, Error>
}

final class DefaultFetchShopCategoryListUseCase: FetchShopCategoryListUseCase {
    private let shopRepository: ShopRepository
    
    init(shopRepository: ShopRepository) {
      self.shopRepository = shopRepository
    }
    
    func execute() -> AnyPublisher<ShopCategoryDTO, Error> {
        return shopRepository.fetchShopCategoryList()
            .map { shopCategoryDTO in
                return self.removeFirstCategory(in: shopCategoryDTO)
            }.eraseToAnyPublisher()
    }
    
    private func removeFirstCategory(in shopCategoryDTO: ShopCategoryDTO) -> ShopCategoryDTO {
        var shopCategory = shopCategoryDTO
        if shopCategory.shopCategories.count > 1 {
            shopCategory.totalCount -= 1
        }
        return shopCategory
    }
}

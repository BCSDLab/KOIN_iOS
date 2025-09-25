//
//  FetchShopCategoryListUseCase.swift
//  koin
//
//  Created by 김나훈 on 5/22/24.
//

import Combine

protocol FetchShopCategoryListUseCase {
    func execute() -> AnyPublisher<ShopCategoryDto, Error>
}

final class DefaultFetchShopCategoryListUseCase: FetchShopCategoryListUseCase {
    private let shopRepository: ShopRepository
    
    init(shopRepository: ShopRepository) {
      self.shopRepository = shopRepository
    }
    
    func execute() -> AnyPublisher<ShopCategoryDto, Error> {
        return shopRepository.fetchShopCategoryList()
            .map { shopCategoryDto in
                return self.removeFirstCategory(in: shopCategoryDto)
            }.eraseToAnyPublisher()
    }
    
    private func removeFirstCategory(in shopCategoryDto: ShopCategoryDto) -> ShopCategoryDto {
        var shopCategory = shopCategoryDto
        if shopCategory.shopCategories.count > 1 {
            shopCategory.totalCount -= 1
        }
        return shopCategory
    }
}

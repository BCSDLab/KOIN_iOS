//
//  SearchShopUseCase.swift
//  koin
//
//  Created by 김나훈 on 5/27/24.
//

import Combine

protocol SearchShopUseCase {
    func execute(text: String) -> AnyPublisher<RelatedKeywordsDto, Error>
}

final class DefaultSearchShopUseCase: SearchShopUseCase {
    private let shopRepository: ShopRepository
    
    init(shopRepository: ShopRepository) {
        self.shopRepository = shopRepository
    }
    
    func execute(text: String) -> AnyPublisher<RelatedKeywordsDto, Error> {
        return shopRepository.searchRelatedQuery(text: text)
    }
    
}

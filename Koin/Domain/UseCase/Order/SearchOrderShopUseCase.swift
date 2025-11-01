//
//  SearchOrderShopUseCase.swift
//  koin
//
//  Created by 이은지 on 7/10/25.
//

import Combine

protocol SearchOrderShopUseCase {
    func execute(text: String) -> AnyPublisher<RelatedKeywordsDto, Error>
}

final class DefaultSearchOrderShopUseCase: SearchOrderShopUseCase {
    private let orderShopRepository: OrderShopRepository
    
    init(orderShopRepository: OrderShopRepository) {
        self.orderShopRepository = orderShopRepository
    }
    
    func execute(text: String) -> AnyPublisher<RelatedKeywordsDto, Error> {
        return orderShopRepository.searchRelatedQuery(text: text)
    }
    
}

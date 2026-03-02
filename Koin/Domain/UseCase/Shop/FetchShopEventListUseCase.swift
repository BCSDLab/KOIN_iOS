//
//  FetchShopEventListUseCase.swift
//  koin
//
//  Created by 김나훈 on 6/11/24.
//

import Combine

protocol FetchShopEventListUseCase {
    func execute(shopId: Int) -> AnyPublisher<[ShopEvent], ErrorResponse>
}

final class DefaultFetchShopEventListUseCase: FetchShopEventListUseCase {
  
    private let shopRepository: ShopRepository
    
    init(shopRepository: ShopRepository) {
        self.shopRepository = shopRepository
    }
    
    func execute(shopId: Int) -> AnyPublisher<[ShopEvent], ErrorResponse> {
        return shopRepository.fetchShopEventList(requestModel: FetchShopDataRequest(shopId: shopId)).map { eventsDto in
             eventsDto.events ?? []
        }.map { events in
            events.map { $0.toDomain() }
        }.eraseToAnyPublisher()
    }
}


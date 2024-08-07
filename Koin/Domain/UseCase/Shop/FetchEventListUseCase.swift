//
//  FetchEventListUseCase.swift
//  koin
//
//  Created by 김나훈 on 5/22/24.
//

import Combine

protocol FetchEventListUseCase {
    func execute() -> AnyPublisher<EventsDTO, Error>
}

final class DefaultFetchEventListUseCase: FetchEventListUseCase {
    
    private let shopRepository: ShopRepository
    
    init(shopRepository: ShopRepository) {
      self.shopRepository = shopRepository
    }
    
    func execute() -> AnyPublisher<EventsDTO, Error> {
        return shopRepository.fetchEventList()
    }
}

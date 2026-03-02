//
//  FetchShopListUseCase.swift
//  koin
//
//  Created by 김나훈 on 5/22/24.
//

import Combine

protocol FetchShopListUseCase {
    func execute(requestModel: FetchShopListRequest) -> AnyPublisher<[Shop], Error>
}

final class DefaultFetchShopListUseCase: FetchShopListUseCase {
    
    private let shopRepository: ShopRepository
    
    init(shopRepository: ShopRepository) {
        self.shopRepository = shopRepository
    }
    
    func execute(requestModel: FetchShopListRequest) -> AnyPublisher<[Shop], Error> {
        return shopRepository.fetchShopList(requestModel: requestModel)
            .map { dto in
                return dto.toDomain() 
            }
            .eraseToAnyPublisher()
    }
}


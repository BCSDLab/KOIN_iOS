//
//  FetchShopDataUseCase.swift
//  koin
//
//  Created by 김나훈 on 6/11/24.
//

import Combine

protocol FetchShopDataUseCase {
    func execute(shopId: Int) -> AnyPublisher<ShopData, Error>
}

final class DefaultFetchShopDataUseCase: FetchShopDataUseCase {
    
    private let shopRepository: ShopRepository
    
    init(shopRepository: ShopRepository) {
        self.shopRepository = shopRepository
    }
    
    func execute(shopId: Int) -> AnyPublisher<ShopData, Error> {
        return shopRepository.fetchShopData(requestModel: FetchShopDataRequest(shopId: shopId)).map { shopDataDTO in
            shopDataDTO.toDomain()
        }.eraseToAnyPublisher()
    }
}

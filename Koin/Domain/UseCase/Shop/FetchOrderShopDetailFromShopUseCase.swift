//
//  FetchOrderShopDetailFromShopUseCase.swift
//  koin
//
//  Created by 홍기정 on 10/31/25.
//

import Foundation
import Combine

protocol FetchOrderShopDetailFromShopUseCase {
    func execute(shopId: Int) -> AnyPublisher<OrderShopDetail, Error>
}

final class DefaultFetchOrderShopDetailFromShopUseCase: FetchOrderShopDetailFromShopUseCase {
    
    private let repository: ShopRepository
    
    init(repository: ShopRepository) {
        self.repository = repository
    }
    
    func execute(shopId: Int) -> AnyPublisher<OrderShopDetail, Error> {
        repository.fetchShopData(requestModel: FetchShopDataRequest(shopId: shopId)).map { shopDataDto in
            return OrderShopDetail(from: shopDataDto)
        }.eraseToAnyPublisher()
    }
    
}

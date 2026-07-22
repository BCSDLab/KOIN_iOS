//
//  FetchShopCountUseCase.swift
//  koin
//
//  Created by 홍기정 on 6/5/26.
//

import Foundation
import Combine

protocol FetchShopCountUseCase {
    func execute() -> AnyPublisher<ShopCount, ErrorResponse>
}

final class DefaultFetchShopCountUseCase: FetchShopCountUseCase {

    private let shopRepository: ShopRepository

    init(shopRepository: ShopRepository) {
        self.shopRepository = shopRepository
    }

    func execute() -> AnyPublisher<ShopCount, ErrorResponse> {
        shopRepository.fetchShopCount()
    }
}

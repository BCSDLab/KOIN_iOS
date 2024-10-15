//
//  FetchBeneficialShopUseCase.swift
//  koin
//
//  Created by 김나훈 on 9/23/24.
//

import Combine

protocol FetchBeneficialShopUseCase {
    func execute(id: Int) -> AnyPublisher<[Shop], Error>
}

final class DefaultFetchBeneficialShopUseCase: FetchBeneficialShopUseCase {

    private let shopRepository: ShopRepository
    
    init(shopRepository: ShopRepository) {
        self.shopRepository = shopRepository
    }

    func execute(id: Int) -> AnyPublisher<[Shop], Error> {
        return shopRepository.fetchBeneficialShops(id: id)
            .map { $0.toDomain() }  
            .eraseToAnyPublisher()
    }
}

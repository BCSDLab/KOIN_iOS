//
//  FetchShopBenefitUseCase.swift
//  koin
//
//  Created by 김나훈 on 9/23/24.
//

import Combine

protocol FetchShopBenefitUseCase {
    func execute() -> AnyPublisher<ShopBenefitsDTO, Error>
}

final class DefaultFetchShopBenefitUseCase: FetchShopBenefitUseCase {
    
    private let shopRepository: ShopRepository
    
    init(shopRepository: ShopRepository) {
        self.shopRepository = shopRepository
    }
    
    func execute() -> AnyPublisher<ShopBenefitsDTO, Error> {
        return shopRepository.fetchShopBenefits()
    }
}

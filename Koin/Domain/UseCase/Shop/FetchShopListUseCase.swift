//
//  FetchShopListUseCase.swift
//  koin
//
//  Created by 김나훈 on 5/22/24.
//

import Combine

protocol FetchShopListUseCase {
    func execute(id: Int) -> AnyPublisher<ShopsDTO, Error>
}

final class DefaultFetchShopListUseCase: FetchShopListUseCase {
    
    private let shopRepository: ShopRepository
    
    init(shopRepository: ShopRepository) {
        self.shopRepository = shopRepository
    }
    
    func execute(id: Int) -> AnyPublisher<ShopsDTO, Error> {
        return shopRepository.fetchShopList()
            .map { shopDTO in
                return self.filterShops(by: id, in: shopDTO)
            }.eraseToAnyPublisher()
    }
    
    private func filterShops(by selectedId: Int, in shopDTO: ShopsDTO) -> ShopsDTO {
        var updatedShopDTO = shopDTO
        
        if selectedId != 0 {
            updatedShopDTO.shops = updatedShopDTO.shops?.filter { shop in
                shop.categoryIds.contains(selectedId)
            }
        }
        return updatedShopDTO
    }
}


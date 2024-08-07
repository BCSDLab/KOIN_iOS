//
//  SearchShopUseCase.swift
//  koin
//
//  Created by 김나훈 on 5/27/24.
//

import Foundation

protocol SearchShopUseCase {
    func execute(text: String, shop: ShopsDTO) -> ShopsDTO
}

final class DefaultSearchShopUseCase: SearchShopUseCase {
    private let shopRepository: ShopRepository
    
    init(shopRepository: ShopRepository) {
        self.shopRepository = shopRepository
    }
    
    func execute(text: String, shop: ShopsDTO) -> ShopsDTO {
        if text.isEmpty { return shop }
        
        let filteredShops = shop.shops?.filter { $0.name.contains(upperText(text)) } ?? []
        return ShopsDTO(count: 0, shops: filteredShops)
    }
    
    private func upperText(_ text: String) -> String {
        let upperedText = text.uppercased()
        return upperedText
    }
    
}

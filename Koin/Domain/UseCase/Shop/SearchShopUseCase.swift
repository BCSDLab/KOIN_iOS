//
//  SearchShopUseCase.swift
//  koin
//
//  Created by 김나훈 on 5/27/24.
//

import Foundation

protocol SearchShopUseCase {
    func execute(text: String, shops: [Shop], categoryId: Int) -> [Shop]
}

final class DefaultSearchShopUseCase: SearchShopUseCase {
    private let shopRepository: ShopRepository
    
    init(shopRepository: ShopRepository) {
        self.shopRepository = shopRepository
    }
    
    func execute(text: String, shops: [Shop], categoryId: Int) -> [Shop] {
        if text.isEmpty {
            if categoryId != 0 {
                return shops.filter{ $0.categoryIds.contains(categoryId)}
            } else {
                return shops
            }
        }
        return shops.filter { $0.name.contains(upperText(text)) }
    }
    
    private func upperText(_ text: String) -> String {
        let upperedText = text.uppercased()
        return upperedText
    }
    
}

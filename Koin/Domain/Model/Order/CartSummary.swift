//
//  CartSummary.swift
//  koin
//
//  Created by 홍기정 on 9/15/25.
//

import Foundation

struct CartSummary {
    let shopMinimumOrderAmount: Int
    let cartItemsAmount: Int
    let isAvailable: Bool
}

extension CartSummary {
    
    init(from dto: CartSummaryDto){
        self.shopMinimumOrderAmount = dto.shopMinimumOrderAmount
        self.cartItemsAmount = dto.cartItemsAmount
        self.isAvailable = dto.isAvailable
    }    
}


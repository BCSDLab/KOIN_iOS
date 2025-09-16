//
//  CartSummary.swift
//  koin
//
//  Created by 홍기정 on 9/15/25.
//

import Foundation

struct CartSummary {
    let orderableShopId: Int
    let shopMinimumOrderAmount: Int
    let cartItemsAmount: Int
    let isAvailable: Bool

    enum CodingKeys: String, CodingKey {
        case orderableShopId = "orderable_shop_id"
        case shopMinimumOrderAmount = "shop_minimum_order_amount"
        case cartItemsAmount = "cart_items_amount"
        case isAvailable = "is_available"
    }
}

extension CartSummary {
    
    init(from dto: CartSummaryDTO){
        self.orderableShopId = dto.orderableShopId
        self.shopMinimumOrderAmount = dto.shopMinimumOrderAmount
        self.cartItemsAmount = dto.cartItemsAmount
        self.isAvailable = dto.isAvailable
    }    
}


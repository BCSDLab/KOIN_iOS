//
//  CartItemsCount.swift
//  koin
//
//  Created by 홍기정 on 9/15/25.
//

import Foundation

struct CartItemsCount {
    let itemTypeCount: Int
    let totalQuantity: Int

    enum CodingKeys: String, CodingKey {
        case itemTypeCount = "item_type_count"
        case totalQuantity = "total_quantity"
    }
}
extension CartItemsCount {
    init(from dto: CartItemsCountDTO) {
        self.itemTypeCount = dto.itemTypeCount
        self.totalQuantity = dto.totalQuantity
    }
}

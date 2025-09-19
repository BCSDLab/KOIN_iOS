//
//  CartItemsCount.swift
//  koin
//
//  Created by 홍기정 on 9/15/25.
//

import Foundation

struct CartItemsCount {
    let totalQuantity: Int
}
extension CartItemsCount {
    init(from dto: CartItemsCountDTO) {
        self.totalQuantity = dto.totalQuantity
    }
}

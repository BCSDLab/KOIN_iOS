//
//  Cart.swift
//  koin
//
//  Created by 홍기정 on 9/16/25.
//

import Foundation

struct Cart {
    let orderableShopId: Int?
}
extension Cart {
    init(from dto: CartDTO) {
        self.orderableShopId = dto.orderableShopId
    }
}

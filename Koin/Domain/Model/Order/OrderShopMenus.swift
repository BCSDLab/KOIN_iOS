//
//  OrderShopMenus.swift
//  koin
//
//  Created by 홍기정 on 9/10/25.
//

import Foundation

struct OrderShopMenus {
    let menuGroupId: Int
    let menuGroupName: String
    let menus: [OrderShopMenu]
}

struct OrderShopMenu {
    let id: Int
    let name: String
    let description: String?
    let thumbnailImage: String?
    let isSoldOut: Bool
    let prices: [Price]
}

struct Price {
    let id: Int
    let name: String?
    let price: Int
}

extension OrderShopMenus {
    init(from dto: OrderShopMenusDTO) {
        self.menuGroupId = dto.menuGroupId
        self.menuGroupName = dto.menuGroupName
        self.menus = dto.menus.map { orderShopMenuDTO in
            OrderShopMenu(from: orderShopMenuDTO)
        }
    }
}

extension OrderShopMenu {
    init(from dto: OrderShopMenuDTO) {
        self.id = dto.id
        self.name = dto.name
        self.description = dto.description
        self.thumbnailImage = dto.thumbnailImage
        self.isSoldOut = dto.isSoldOut
        self.prices = dto.prices.map { priceDTO in
            Price(from: priceDTO)
        }
    }
}

extension Price {
    init(from dto: PriceDTO) {
        self.id = dto.id
        self.name = dto.name
        self.price = dto.price
    }
}

//
//  OrderShopMenus.swift
//  koin
//
//  Created by 홍기정 on 9/10/25.
//

import Foundation

struct OrderShopMenus {
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
    let name: String?
    let price: Int
}

extension OrderShopMenus {
    init(from dto: MenuCategory) {
        self.menuGroupName = dto.name
        
        guard let menus = dto.menus else {
            self.menus = []
            return
        }
        self.menus = menus.map {
            OrderShopMenu(from: $0)
        }
    }
}
extension OrderShopMenu {
    init(from dto: Menu) {
        self.id = dto.id
        self.name = dto.name ?? "" // nil??
        self.description = dto.description
        self.thumbnailImage = dto.imageUrls?.first ?? nil
        self.isSoldOut = false
        
        if dto.isSingle, let singlePrice = dto.singlePrice {
            self.prices = [Price(name: dto.name, price: singlePrice)]
        } else if let optionPrices = dto.optionPrices {
            self.prices = optionPrices.map { optionPrice in
                Price(from: optionPrice)
            }
        } else {
            self.prices = []
        }
    }
}

extension Price {
    init(from dto: OptionPrice) {
        self.name = dto.option
        self.price = dto.price
    }
}

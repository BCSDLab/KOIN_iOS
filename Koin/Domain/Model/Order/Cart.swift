//
//  Cart.swift
//  koin
//
//  Created by 홍기정 on 9/16/25.
//

import Foundation

struct Cart {
    let shopName: String?
    let shopThumbnailImageUrl: String?
    let orderableShopId: Int?
    let isDeliveryAvailable, isTakeoutAvailable: Bool
    let shopMinimumOrderAmount: Int
    var items: [CartItem]
    let itemsAmount, deliveryFee, totalAmount, finalPaymentAmount: Int
}

struct CartItem: Equatable {
    let cartMenuItemId, orderableShopMenuId: Int
    let name: String
    let menuThumbnailImageUrl: String?
    let quantity, totalAmount: Int
    let price: CartPrice
    let options: [Option]
    let isModified: Bool
}

struct Option: Equatable {
    let optionGroupName, optionName: String
    let optionPrice: Int
}

struct CartPrice: Equatable {
    let name: String?
    let price: Int
}

extension Cart {
    init(from dto: CartDto) {
        self.shopName = dto.shopName
        self.shopThumbnailImageUrl = dto.shopThumbnailImageUrl
        self.orderableShopId = dto.orderableShopId
        self.isDeliveryAvailable = dto.isDeliveryAvailable
        self.isTakeoutAvailable = dto.isTakeoutAvailable
        self.shopMinimumOrderAmount = dto.shopMinimumOrderAmount
        self.items = dto.items.map {
            CartItem(from: $0)
        }
        self.itemsAmount = dto.itemsAmount
        self.deliveryFee = dto.deliveryFee
        self.totalAmount = dto.totalAmount
        self.finalPaymentAmount = dto.finalPaymentAmount
    }
    static func empty() -> Cart {
        Cart(shopName: nil, shopThumbnailImageUrl: nil, orderableShopId: nil, isDeliveryAvailable: true, isTakeoutAvailable: true, shopMinimumOrderAmount: 0, items: [], itemsAmount: 0, deliveryFee: 0, totalAmount: 0, finalPaymentAmount: 0)
    }
}

extension CartItem {
    init(from dto: CartItemDto) {
        self.cartMenuItemId = dto.cartMenuItemId
        self.orderableShopMenuId = dto.orderableShopMenuId
        self.name = dto.name
        self.menuThumbnailImageUrl = dto.menuThumbnailImageUrl
        self.quantity = dto.quantity
        self.totalAmount = dto.totalAmount
        self.price = CartPrice(from: dto.price)
        self.options = dto.options.map {
            Option(from: $0)
        }
        self.isModified = dto.isModified
    }
}

extension Option {
    init(from dto: OptionDto){
        self.optionGroupName = dto.optionGroupName
        self.optionName = dto.optionName
        self.optionPrice = dto.optionPrice
    }
}

extension CartPrice {
    init(from dto: CartPriceDto) {
        self.name = dto.name
        self.price = dto.price
    }
}

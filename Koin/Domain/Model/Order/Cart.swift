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

struct CartItem {
    let cartMenuItemId, orderableShopMenuId: Int
    let name: String
    let menuThumbnailImageUrl: String?
    let quantity, totalAmount: Int
    let price: CartPrice
    let options: [Option]
    let isModified: Bool
}

struct Option {
    let optionGroupName, optionName: String
    let optionPrice: Int
}

struct CartPrice {
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
    static func dummy() -> Cart {
        Cart(shopName: "굿모닝살로만치킨",
             shopThumbnailImageUrl: "https://static.koreatech.in/upload/owners/2024/03/28/ebef80af-9d18-44c8-b4dd-44c64f21a520-1711617869236/1693645787165.jpg",
             orderableShopId: 2,
             isDeliveryAvailable: true,
             isTakeoutAvailable: false,
             shopMinimumOrderAmount: 14000,
             items: [CartItem(
                cartMenuItemId: 906,
                orderableShopMenuId: 11,
                name: "후라이드 치킨",
                menuThumbnailImageUrl: "https://static.koreatech.in/upload/owners/2024/03/06/2d7687d6-57dd-4241-988a-26d2b2855030-1709732308684/20240304_182511.jpg",
                quantity: 2,
                totalAmount: 38000,
                price: CartPrice(
                    name: nil,
                    price: 19000),
                options: [Option(optionGroupName: "옵션1", optionName: "선택1", optionPrice: 10000),
                          Option(optionGroupName: "옵션2", optionName: "선택2", optionPrice: 5000),
                          Option(optionGroupName: "옵션3", optionName: "선택3", optionPrice: 12345)],
                isModified: false),
                 CartItem(
                    cartMenuItemId: 906,
                    orderableShopMenuId: 11,
                    name: "후라이드 치킨",
                    menuThumbnailImageUrl: "https://static.koreatech.in/upload/owners/2024/03/06/2d7687d6-57dd-4241-988a-26d2b2855030-1709732308684/20240304_182511.jpg",
                    quantity: 1,
                    totalAmount: 38000,
                    price: CartPrice(
                        name: nil,
                        price: 19000),
                    options: [],
                    isModified: false)],
             itemsAmount: 62500,
             deliveryFee: 1500,
             totalAmount: 64000,
             finalPaymentAmount: 64000)
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

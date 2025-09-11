//
//  OrderShopMenus.swift
//  koin
//
//  Created by 홍기정 on 9/10/25.
//

import Foundation

// MARK: - OrderShopMenus
struct OrderShopMenus {
    let menuGroupId: Int
    let menuGroupName: String
    let menus: [OrderShopMenu]
}

// MARK: - OrderShopMenu
struct OrderShopMenu {
    let id: Int
    let name: String
    let description: String?
    let thumbnailImage: String
    let isSoldOut: Bool
    let prices: [Price]
}

// MARK: - Price
struct Price {
    let id: Int
    let name: Name?
    let price: Int
}

enum Name: String {
    case small = "소"
    case medium = "중"
    case large = "대"
    case extraLarge = "특대"
}

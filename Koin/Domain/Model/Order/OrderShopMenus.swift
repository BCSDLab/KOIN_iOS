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
    case 대 = "대"
    case 소 = "소"
    case 중 = "중"
    case 특대 = "특대"
}

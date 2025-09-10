//
//  OrderShopMenusGroup.swift
//  koin
//
//  Created by 홍기정 on 9/10/25.
//

import Foundation

// MARK: - CoopShopModel
struct OrderShopMenusGroups: Codable {
    let count: Int
    let menuGroups: [MenuGroup]

    enum CodingKeys: String, CodingKey {
        case count
        case menuGroups = "menu_groups"
    }
}

// MARK: - MenuGroup
struct MenuGroup: Codable {
    let id: Int
    let name: String
}


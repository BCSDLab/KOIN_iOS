//
//  OrderShopMenusGroup.swift
//  koin
//
//  Created by 홍기정 on 9/10/25.
//

import Foundation

// MARK: - CoopShopModel
struct OrderShopMenusGroups {
    let count: Int
    let menuGroups: [MenuGroup]
}

// MARK: - MenuGroup
struct MenuGroup: Codable {
    let id: Int
    let name: String
}

extension OrderShopMenusGroups {
    
    static func dummy() -> OrderShopMenusGroups {
        
        return OrderShopMenusGroups(
            count: 0,
            menuGroups: [
                MenuGroup(id: 0, name: "메인메뉴"),
                MenuGroup(id: 1, name: "추천메뉴"),
                MenuGroup(id: 2, name: "세트메뉴"),
                MenuGroup(id: 3, name: "사이드"),
                MenuGroup(id: 4, name: "메인메뉴"),
                MenuGroup(id: 5, name: "추천메뉴"),
                MenuGroup(id: 6, name: "세트메뉴"),
                MenuGroup(id: 7, name: "사이드")
            ])
    }
}


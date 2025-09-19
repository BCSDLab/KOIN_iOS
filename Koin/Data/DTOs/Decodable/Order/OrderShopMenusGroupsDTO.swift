//
//  OrderShopMenusGroups.swift
//  koin
//
//  Created by 홍기정 on 9/13/25.
//

import Foundation

struct OrderShopMenusGroupsDto: Decodable {
    let count: Int
    let menuGroups: [MenuGroupDto]
    
    enum CodingKeys: String, CodingKey {
    case count
    case menuGroups = "menu_groups"
    }
}

struct MenuGroupDto: Decodable {
    let id: Int
    let name: String
}

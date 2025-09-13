//
//  OrderShopMenusGroups.swift
//  koin
//
//  Created by 홍기정 on 9/13/25.
//

import Foundation

struct OrderShopMenusGroupsDTO: Decodable {
    let count: Int
    let menuGroups: [MenuGroupDTO]
    
    enum CodingKeys: String, CodingKey {
    case count
    case menuGroups = "menu_groups"
    }
}

struct MenuGroupDTO: Decodable {
    let id: Int
    let name: String
}

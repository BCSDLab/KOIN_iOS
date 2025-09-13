//
//  OrderShopMenusGroup.swift
//  koin
//
//  Created by 홍기정 on 9/10/25.
//

import Foundation

struct OrderShopMenusGroups {
    let count: Int
    let menuGroups: [MenuGroup]
}

struct MenuGroup {
    let id: Int
    let name: String
}

extension OrderShopMenusGroups {
    init(from dto: OrderShopMenusGroupsDTO) {
        self.count = dto.count
        self.menuGroups = dto.menuGroups.map { menuGroupDTO in
            MenuGroup(from: menuGroupDTO)
        }
    }
}

extension MenuGroup {
    init(from dto: MenuGroupDTO) {
        self.id = dto.id
        self.name = dto.name
    }
}

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
    init(from dto: ShopMenusCategoryDTO) {
        self.count = dto.count
        self.menuGroups = dto.menuCategories.map { menuCategoryDTO in
            return MenuGroup(from: menuCategoryDTO)
        }
    }
}

extension MenuGroup {
    init(from dto: MenuGroupDTO) {
        self.id = dto.id
        self.name = dto.name
    }
    init(from dto: ShopMenuCategoryDTO) {
        self.id = dto.id
        self.name = dto.name
    }
}

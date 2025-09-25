//
//  OrderShopMenusGroup.swift
//  koin
//
//  Created by 홍기정 on 9/10/25.
//

import Foundation

struct OrderShopMenusGroups {
    let menuGroups: [MenuGroup]
}
struct MenuGroup {
    let name: String
}

extension OrderShopMenusGroups {
    init(from dto: OrderShopMenusGroupsDto) {
        self.menuGroups = dto.menuGroups.map { menuGroupDto in
            MenuGroup(from: menuGroupDto)
        }
    }
    init(from dto: ShopMenusCategoryDto) {
        self.menuGroups = dto.menuCategories.map { menuCategoryDto in
            return MenuGroup(from: menuCategoryDto)
        }
    }
}

extension MenuGroup {
    init(from dto: MenuGroupDto) {
        self.name = dto.name
    }
    init(from dto: ShopMenuCategoryDto) {
        self.name = dto.name
    }
}

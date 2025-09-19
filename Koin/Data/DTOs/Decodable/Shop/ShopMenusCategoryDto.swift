//
//  ShopMenusCategoryDto.swift
//  koin
//
//  Created by 홍기정 on 9/15/25.
//

import Foundation

struct ShopMenusCategoryDto: Decodable {
    let count: Int
    let menuCategories: [ShopMenuCategoryDto]

    enum CodingKeys: String, CodingKey {
        case count
        case menuCategories = "menu_categories"
    }
}

// MARK: - MenuCategory
struct ShopMenuCategoryDto: Decodable {
    let id: Int
    let name: String
}

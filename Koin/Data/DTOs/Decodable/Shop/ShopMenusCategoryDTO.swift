//
//  ShopMenusCategoryDTO.swift
//  koin
//
//  Created by 홍기정 on 9/15/25.
//

import Foundation

struct ShopMenusCategoryDTO: Decodable {
    let count: Int
    let menuCategories: [ShopMenuCategoryDTO]

    enum CodingKeys: String, CodingKey {
        case count
        case menuCategories = "menu_categories"
    }
}

// MARK: - MenuCategory
struct ShopMenuCategoryDTO: Decodable {
    let id: Int
    let name: String
}

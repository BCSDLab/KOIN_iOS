//
//  ShopCategoryDTO.swift
//  Koin
//
//  Created by 김나훈 on 3/12/24.
//

import Foundation

struct ShopCategoryDTO: Codable {
    var totalCount: Int
    var shopCategories: [ShopCategory]

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case shopCategories = "shop_categories"
    }
}

struct ShopCategory: Codable {
    let id: Int
    let name: String
    let imageURL: String

    enum CodingKeys: String, CodingKey {
        case id, name
        case imageURL = "image_url"
    }
}

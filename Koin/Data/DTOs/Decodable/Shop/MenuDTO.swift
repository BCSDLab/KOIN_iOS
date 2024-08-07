//
//  MenuDTO.swift
//  Koin
//
//  Created by 김나훈 on 3/15/24.
// nullable 주민경 2024/05/02


import Foundation

struct MenuDTO: Codable {
    let count: Int
    let menuCategories: [MenuCategory]?

    enum CodingKeys: String, CodingKey {
        case count
        case menuCategories = "menu_categories"
    }
}

// MARK: - MenuCategory
struct MenuCategory: Codable {
    let id: Int
    let menus: [Menu]?
    let name: String
}

// MARK: - Menu
struct Menu: Codable {
    let description: String?
    let id: Int
    let imageUrls: [String]?
    let isHidden, isSingle: Bool
    let name: String?
    let optionPrices: [OptionPrice]?
    let singlePrice: Int?

    enum CodingKeys: String, CodingKey {
        case description, id
        case imageUrls = "image_urls"
        case isHidden = "is_hidden"
        case isSingle = "is_single"
        case name
        case optionPrices = "option_prices"
        case singlePrice = "single_price"
    }
}

// MARK: - OptionPrice
struct OptionPrice: Codable {
    let option: String
    let price: Int
}

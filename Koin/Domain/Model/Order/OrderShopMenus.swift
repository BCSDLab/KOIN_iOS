// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let coopShopModel = try? JSONDecoder().decode(CoopShopModel.self, from: jsonData)

import Foundation

// MARK: - OrderShopMenus
struct OrderShopMenus: Codable {
    let menuGroupID: Int
    let menuGroupName: String
    let menus: [OrderShopMenu]

    enum CodingKeys: String, CodingKey {
        case menuGroupID = "menu_group_id"
        case menuGroupName = "menu_group_name"
        case menus
    }
}

// MARK: - OrderShopMenu
struct OrderShopMenu: Codable {
    let id: Int
    let name: String
    let description: String?
    let thumbnailImage: String
    let isSoldOut: Bool
    let prices: [Price]

    enum CodingKeys: String, CodingKey {
        case id, name, description
        case thumbnailImage = "thumbnail_image"
        case isSoldOut = "is_sold_out"
        case prices
    }
}

// MARK: - Price
struct Price: Codable {
    let id: Int
    let name: Name?
    let price: Int
}

enum Name: String, Codable {
    case 대 = "대"
    case 소 = "소"
    case 중 = "중"
    case 특대 = "특대"
}

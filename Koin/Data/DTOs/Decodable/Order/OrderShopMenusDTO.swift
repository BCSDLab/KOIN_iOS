//
//  OrderShopMenusDTO.swift
//  koin
//
//  Created by 홍기정 on 9/13/25.
//

import Foundation

struct OrderShopMenusDTO: Decodable {
    let menuGroupId: Int
    let menuGroupName: String
    let menus: [OrderShopMenuDTO]
    
    enum CodingKeys: String, CodingKey {
        case menuGroupId = "menu_group_id"
        case menuGroupName = "menu_group_name"
        case menus
    }
}

struct OrderShopMenuDTO: Decodable {
    let id: Int
    let name: String
    let description: String?
    let thumbnailImage: String?
    let isSoldOut: Bool
    let prices: [PriceDTO]
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case thumbnailImage = "thumbnail_image"
        case isSoldOut = "is_sold_out"
        case prices
    }
}

struct PriceDTO: Decodable {
    let id: Int
    let name: String?
    let price: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case price
    }
}

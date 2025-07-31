//
//  ShopEventDTO.swift
//  koin
//
//  Created by 이은지 on 7/31/25.
//

import Foundation

struct OrderShopEventDTO: Decodable {
    let orderableShopId: Int
    let shopId: Int
    let shopName: String
    let eventId: Int
    let title: String
    let content: String
    let thumbnailImages: [String]
    let startDate: String
    let endDate: String

    enum CodingKeys: String, CodingKey {
        case orderableShopId = "orderable_shop_id"
        case shopId = "shop_id"
        case shopName = "shop_name"
        case eventId = "event_id"
        case title, content
        case thumbnailImages = "thumbnail_images"
        case startDate = "start_date"
        case endDate = "end_date"
    }
}

struct OrderShopEventListResponseDTO: Decodable {
    let shopEvents: [OrderShopEventDTO]

    enum CodingKeys: String, CodingKey {
        case shopEvents = "shop_events"
    }
}

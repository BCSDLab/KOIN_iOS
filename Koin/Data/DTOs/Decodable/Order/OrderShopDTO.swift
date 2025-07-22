//
//  OrderShopDTO.swift
//  koin
//
//  Created by 이은지 on 7/7/25.
//

import Foundation

struct OrderShopDTO: Codable {
    let shopId: Int
    let orderableShopId: Int
    let name: String
    let isDeliveryAvailable: Bool
    let isTakeoutAvailable: Bool
    let serviceEvent: Bool
    let minimumOrderAmount: Int
    let ratingAverage: Double
    let reviewCount: Int
    let minimumDeliveryTip: Int
    let maximumDeliveryTip: Int
    let isOpen: Bool
    let categoryIds: [Int]
    let imageUrls: [String]
    let open: [OpenInfoDTO]
    let openStatus: String

    enum CodingKeys: String, CodingKey {
        case shopId = "shop_id"
        case orderableShopId = "orderable_shop_id"
        case name
        case isDeliveryAvailable = "is_delivery_available"
        case isTakeoutAvailable = "is_takeout_available"
        case serviceEvent = "service_event"
        case minimumOrderAmount = "minimum_order_amount"
        case ratingAverage = "rating_average"
        case reviewCount = "review_count"
        case minimumDeliveryTip = "minimum_delivery_tip"
        case maximumDeliveryTip = "maximum_delivery_tip"
        case isOpen = "is_open"
        case categoryIds = "category_ids"
        case imageUrls = "image_urls"
        case open
        case openStatus = "open_status"
    }
}

struct OpenInfoDTO: Codable {
    let dayOfWeek: String
    let closed: Bool
    let openTime: String?
    let closeTime: String?

    enum CodingKeys: String, CodingKey {
        case dayOfWeek = "day_of_week"
        case closed
        case openTime = "open_time"
        case closeTime = "close_time"
    }
}

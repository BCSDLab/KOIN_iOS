//
//  OrderShop.swift
//  koin
//
//  Created by 이은지 on 6/30/25.
//

import Foundation

struct OrderShop: Decodable {
    let shopId: Int
    let orderableShopId: Int
    let name: String
    let isDeliveryAvailable: Bool
    let isTakeoutAvailable: Bool
    let minimumOrderAmount: Int
    let ratingAverage: Double
    let reviewCount: Int
    let minimumDeliveryTip: Int
    let maximumDeliveryTip: Int
    let isOpen: Bool
    let categoryIds: [Int]
    let imageUrls: [String]
    let orderShopOpen: [OrderOpen]
    let openStatus: String

    enum CodingKeys: String, CodingKey {
        case shopId = "shop_id"
        case orderableShopId = "orderable_shop_id"
        case name
        case isDeliveryAvailable = "is_delivery_available"
        case isTakeoutAvailable = "is_takeout_available"
        case minimumOrderAmount = "minimum_order_amount"
        case ratingAverage = "rating_average"
        case reviewCount = "review_count"
        case minimumDeliveryTip = "minimum_delivery_tip"
        case maximumDeliveryTip = "maximum_delivery_tip"
        case isOpen = "is_open"
        case categoryIds = "category_ids"
        case imageUrls = "image_urls"
        case orderShopOpen = "open"
        case openStatus = "open_status"
    }
}

struct OrderOpen: Decodable {
    let dayOfWeek: OrderDayOfWeek
    let closed: Bool
    let openTime: String
    let closeTime: String

    enum CodingKeys: String, CodingKey {
        case dayOfWeek = "day_of_week"
        case closed
        case openTime = "open_time"
        case closeTime = "close_time"
    }
}

enum OrderDayOfWeek: String, Decodable {
    case friday = "FRIDAY"
    case monday = "MONDAY"
    case saturday = "SATURDAY"
    case sunday = "SUNDAY"
    case thursday = "THURSDAY"
    case tuesday = "TUESDAY"
    case wednesday = "WEDNESDAY"
}

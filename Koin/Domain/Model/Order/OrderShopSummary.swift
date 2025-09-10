//
//  OrderShopSummary.swift
//  koin
//
//  Created by 홍기정 on 9/10/25.
//

import Foundation

// MARK: - CoopShopModel
struct OrderShopSummary: Codable {
    let shopID, orderableShopID: Int
    let name: String
    let introduction: String?
    let isDeliveryAvailable, isTakeoutAvailable, payCard, payBank: Bool
    let minimumOrderAmount: Int
    let ratingAverage: Double
    let reviewCount, minimumDeliveryTip, maximumDeliveryTip: Int
    let images: [OrderImage]

    enum CodingKeys: String, CodingKey {
        case shopID = "shop_id"
        case orderableShopID = "orderable_shop_id"
        case name, introduction
        case isDeliveryAvailable = "is_delivery_available"
        case isTakeoutAvailable = "is_takeout_available"
        case payCard = "pay_card"
        case payBank = "pay_bank"
        case minimumOrderAmount = "minimum_order_amount"
        case ratingAverage = "rating_average"
        case reviewCount = "review_count"
        case minimumDeliveryTip = "minimum_delivery_tip"
        case maximumDeliveryTip = "maximum_delivery_tip"
        case images
    }
}

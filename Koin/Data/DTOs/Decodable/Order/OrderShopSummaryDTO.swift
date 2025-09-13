//
//  OrderShopSummaryDTO.swift
//  koin
//
//  Created by 홍기정 on 9/13/25.
//

import Foundation

struct OrderShopSummaryDTO: Decodable {
    let shopId: Int
    let orderableShopId: Int
    let name: String
    let introduction: String?
    let isDeliveryAvailable, isTakeoutAvailable, payCard, payBank: Bool
    let minimumOrderAmount: Int
    let ratingAverage: Double
    let reviewCount, minimumDeliveryTip, maximumDeliveryTip: Int
    let images: [OrderImageDTO]
    
    enum CodingKeys: String, CodingKey {
        case shopId = "shop_id"
        case orderableShopId = "orderable_shop_id"
        case name
        case introduction
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

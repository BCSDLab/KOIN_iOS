//
//  OrderShopSummary.swift
//  koin
//
//  Created by 홍기정 on 9/10/25.
//

import Foundation

struct OrderShopSummary {
    let shopId: Int
    let orderableShopId: Int
    let images: [OrderImage]
    let name: String
    let ratingAverage: Double
    let reviewCount: Int
    let isDeliveryAvailable, isTakeoutAvailable, payCard, payBank: Bool
    let minimumOrderAmount: Int
    let minimumDeliveryTip, maximumDeliveryTip: Int
    let introduction: String?
}

extension OrderShopSummary {
    init(from dto: ShopSummaryDto, shopId: Int) {
        self.shopId = shopId
        self.orderableShopId = 0
        self.name = dto.name
        self.introduction = dto.introduction
        self.isDeliveryAvailable = false
        self.isTakeoutAvailable = false
        self.payCard = false
        self.payBank = false
        self.minimumOrderAmount = 0
        self.ratingAverage = Double(dto.ratingAverage)
        self.reviewCount = dto.reviewCount
        self.minimumDeliveryTip = 0
        self.maximumDeliveryTip = 0
        self.images = dto.images.map {
            OrderImage(imageUrl: $0.imageUrl, isThumbnail: $0.isThumbnail)
        }
    }
}

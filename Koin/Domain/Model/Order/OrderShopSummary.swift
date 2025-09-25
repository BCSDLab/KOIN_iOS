//
//  OrderShopSummary.swift
//  koin
//
//  Created by 홍기정 on 9/10/25.
//

import Foundation

struct OrderShopSummary {
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
    init(from dto: OrderShopSummaryDto) {
        self.name = dto.name
        self.introduction = dto.introduction
        self.isDeliveryAvailable = dto.isDeliveryAvailable
        self.isTakeoutAvailable = dto.isTakeoutAvailable
        self.payCard = dto.payCard
        self.payBank = dto.payBank
        self.minimumOrderAmount = dto.minimumOrderAmount
        self.ratingAverage = dto.ratingAverage
        self.reviewCount = dto.reviewCount
        self.minimumDeliveryTip = dto.minimumDeliveryTip
        self.maximumDeliveryTip = dto.maximumDeliveryTip
        self.images = dto.images.map { orderImages in
            OrderImage(from: orderImages)
        }
    }
    init(from dto: ShopSummaryDto) {
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

//
//  OrderShopSummary.swift
//  koin
//
//  Created by 홍기정 on 9/10/25.
//

import Foundation

// MARK: - CoopShopModel
struct OrderShopSummary {
    let shopId: Int
    let orderableShopId: Int
    let name: String
    let introduction: String?
    let isDeliveryAvailable, isTakeoutAvailable, payCard, payBank: Bool
    let minimumOrderAmount: Int
    let ratingAverage: Double
    let reviewCount, minimumDeliveryTip, maximumDeliveryTip: Int
    let images: [OrderImage]
}

extension OrderShopSummary {
    
    static func dummy() -> OrderShopSummary {
        
        return OrderShopSummary(
            shopId: 0,
            orderableShopId: 0,
            name: "굿모닝살로만치킨",
            introduction: "안녕하세요 굿모닝 살로만 치킨입니다!",
            isDeliveryAvailable: true,
            isTakeoutAvailable: false,
            payCard: true, payBank: true,
            minimumOrderAmount: 14000,
            ratingAverage: 4.1,
            reviewCount: 60,
            minimumDeliveryTip: 1500,
            maximumDeliveryTip: 3500,
            images: [OrderImage(imageUrl: "https://static.koreatech.in/upload/market/2021/05/29/85d5a49a-ecd8-4223-8582-ae316f251e27-1622292361626.jpg",isThumbnail: true),OrderImage(imageUrl: "https://static.koreatech.in/upload/market/2021/05/29/85d5a49a-ecd8-4223-8582-ae316f251e27-1622292361626.jpg",isThumbnail: false),OrderImage(imageUrl: "https://static.koreatech.in/upload/market/2021/05/29/85d5a49a-ecd8-4223-8582-ae316f251e27-1622292361626.jpg",isThumbnail: true)])
    }        
}

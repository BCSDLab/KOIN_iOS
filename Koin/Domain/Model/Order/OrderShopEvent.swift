//
//  OrderShopEvent.swift
//  koin
//
//  Created by 이은지 on 7/31/25.
//

import Foundation

struct OrderShopEvent {
    let orderableShopId: Int
    let shopId: Int
    let shopName: String
    let eventId: Int
    let title: String
    let content: String
    let thumbnailImages: [String]
    let startDate: String
    let endDate: String
}

extension OrderShopEvent {
    init(dto: OrderShopEventDTO) {
        self.orderableShopId = dto.orderableShopId
        self.shopId = dto.shopId
        self.shopName = dto.shopName
        self.eventId = dto.eventId
        self.title = dto.title
        self.content = dto.content
        self.thumbnailImages = dto.thumbnailImages
        self.startDate = dto.startDate
        self.endDate = dto.endDate
    }
}

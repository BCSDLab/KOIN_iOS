//
//  ShopSummary.swift
//  koin
//
//  Created by 홍기정 on 9/10/25.
//

import Foundation

struct ShopSummary {
    let name: String
    let images: [ShopImage]
    let ratingAverage: Double
    let reviewCount: Int
    let isDeliveryAvailable: Bool
    let payBank: Bool
    let payCard: Bool
    let maxDeliveryTip: Int
    let phone: String
    let eventTitle: String?
    let menuGroups: [ShopMenuGroup]
}

extension ShopSummary {
    init(summaryDto: ShopSummaryDto, shopData: ShopData, menuDto: MenuDto, eventsDto: EventsDto) {
        self.name = summaryDto.name
        self.images = summaryDto.images.map {
            ShopImage(imageUrl: $0.imageUrl, isThumbnail: $0.isThumbnail)
        }
        self.ratingAverage = summaryDto.ratingAverage
        self.reviewCount = summaryDto.reviewCount
        self.isDeliveryAvailable = shopData.delivery
        self.payBank = shopData.payBank
        self.payCard = shopData.payCard
        self.maxDeliveryTip = shopData.deliveryPrice
        self.phone = shopData.phone
        self.eventTitle = eventsDto.events?.first?.title
        self.menuGroups = (menuDto.menuCategories ?? []).map { ShopMenuGroup(from: $0) }
    }
}

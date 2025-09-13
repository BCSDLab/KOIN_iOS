//
//  OrderShop.swift
//  koin
//
//  Created by 이은지 on 6/30/25.
//


import Foundation

struct OrderShop {
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
    let images: [OrderImage]?
    let openStatus: String
}

struct OrderOpen {
    let dayOfWeek: OrderDayOfWeek
    let closed: Bool
    let openTime: String
    let closeTime: String
}

enum OrderDayOfWeek: String {
    case friday = "FRIDAY"
    case monday = "MONDAY"
    case saturday = "SATURDAY"
    case sunday = "SUNDAY"
    case thursday = "THURSDAY"
    case tuesday = "TUESDAY"
    case wednesday = "WEDNESDAY"
}

extension OrderShop {
    init(dto: OrderShopDTO) {
        shopId = dto.shopId
        orderableShopId = dto.orderableShopId
        name = dto.name
        isDeliveryAvailable = dto.isDeliveryAvailable
        isTakeoutAvailable = dto.isTakeoutAvailable
        serviceEvent = dto.serviceEvent
        minimumOrderAmount = dto.minimumOrderAmount
        ratingAverage = dto.ratingAverage
        reviewCount = dto.reviewCount
        minimumDeliveryTip = dto.minimumDeliveryTip
        maximumDeliveryTip = dto.maximumDeliveryTip
        isOpen = dto.isOpen
        categoryIds = dto.categoryIds
        images = dto.images?.map { OrderImage(dto: $0) }
        openStatus = dto.openStatus
    }
}

extension OrderImage {
    init(dto: OrderImageDTO) {
        imageUrl = dto.imageUrl
        isThumbnail = dto.isThumbnail
    }
}

extension OrderOpen {
    init(dto: OpenInfoDTO) {
        dayOfWeek = OrderDayOfWeek(rawValue: dto.dayOfWeek) ?? .monday
        closed = dto.closed
        openTime = dto.openTime ?? ""
        closeTime = dto.closeTime ?? ""
    }
}


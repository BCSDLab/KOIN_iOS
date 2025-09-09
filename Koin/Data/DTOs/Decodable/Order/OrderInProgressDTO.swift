//
//  OrderInProgressDTO.swift
//  koin
//
//  Created by 이은지 on 9/8/25.
//

import Foundation

struct OrderInProgressDTO: Decodable {
    let orderId: Int
    let orderType: OrderInProgressTypeDTO
    let shopName: String
    let shopThumbnail: String
    let estimatedAt: EstimatedTimeDTO
    let orderStatus: OrderInProgressStatusDTO
    let paymentDescription: String
    let totalAmount: Int
    
    enum CodingKeys: String, CodingKey {
        case orderId = "order_id"
        case orderType = "order_type"
        case shopName = "shop_name"
        case shopThumbnail = "shop_thumbnail"
        case estimatedAt = "estimated_at"
        case orderStatus = "order_status"
        case paymentDescription = "payment_description"
        case totalAmount = "total_amount"
    }
}

// 예상 시각
struct EstimatedTimeDTO: Decodable {
    let hour: Int
    let minute: Int
    let second: Int
    let nano: Int
}

// 주문 타입
enum OrderInProgressTypeDTO: String, Decodable {
    case delivery = "DELIVERY"
    case takeout = "TAKEOUT"
}

// 주문 상태
enum OrderInProgressStatusDTO: String, Decodable {
    case confirming = "CONFIRMING"
    case cooking = "COOKING"
    case packaged = "PACKAGED"
    case pickedUp = "PICKED_UP"
    case delivering = "DELIVERING"
    case delivered = "DELIVERED"
    case canceled = "CANCELED"
}

// DTO → Entity 변환
extension OrderInProgressDTO {
    func toEntity() -> OrderInProgress {
        OrderInProgress(
            id: orderId,
            type: OrderInProgressType(rawValue: orderType.rawValue) ?? .delivery,
            shopName: shopName,
            shopThumbnail: shopThumbnail,
            estimatedTime: String.koreanTimeString(hour: estimatedAt.hour, minute: estimatedAt.minute),
            status: OrderInProgressStatus(rawValue: orderStatus.rawValue) ?? .confirming,
            description: paymentDescription,
            totalAmount: totalAmount
        )
    }
}

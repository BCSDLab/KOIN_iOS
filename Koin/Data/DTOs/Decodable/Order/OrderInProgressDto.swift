//
//  OrderInProgressDto.swift
//  koin
//
//  Created by 이은지 on 9/8/25.
//

import Foundation

struct OrderInProgressDto: Decodable {
    let id: Int
    let orderType: OrderInProgressTypeDto
    let orderableShopName: String
    let orderableShopThumbnail: String
    let estimatedAt: String?
    let orderStatus: OrderInProgressStatusDto
    let orderTitle: String
    let totalAmount: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case orderType = "order_type"
        case orderableShopName = "orderable_shop_name"
        case orderableShopThumbnail = "orderable_shop_thumbnail"
        case estimatedAt = "estimated_at"
        case orderStatus = "order_status"
        case orderTitle = "order_title"
        case totalAmount = "total_amount"
    }
}

// 주문 타입
enum OrderInProgressTypeDto: Decodable {
    case delivery
    case takeout

    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self).uppercased()
        switch raw {
        case "DELIVERY": self = .delivery
        case "TAKEOUT", "TAKE_OUT": self = .takeout
        default:
            self = .takeout
        }
    }
}

// 주문 상태
enum OrderInProgressStatusDto: String, Decodable {
    case confirming = "CONFIRMING"
    case cooking = "COOKING"
    case packaged = "PACKAGED"
    case pickedUp = "PICKED_UP"
    case delivering = "DELIVERING"
    case delivered = "DELIVERED"
    case canceled = "CANCELED"
}

extension OrderInProgressDto {
    func toEntity() -> OrderInProgress {
        let timeText = estimatedAt?.toKoreanTimeString() ?? "시간 미정"

        return OrderInProgress(
            id: id,
            type: OrderInProgressType(rawValue: {
                switch orderType {
                case .delivery: return "DELIVERY"
                case .takeout:  return "TAKEOUT"
                }
            }()) ?? .delivery,
            orderableShopName: orderableShopName,
            orderableShopThumbnail: orderableShopThumbnail,
            estimatedTime: timeText,
            status: OrderInProgressStatus(rawValue: orderStatus.rawValue) ?? .confirming,
            orderTitle: orderTitle,
            totalAmount: totalAmount
        )
    }
}

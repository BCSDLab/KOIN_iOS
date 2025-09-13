//
//  OrderInProgress.swift
//  koin
//
//  Created by 이은지 on 9/8/25.
//

import Foundation

struct OrderInProgress: Hashable {
    let id: Int
    let type: OrderInProgressType
    let orderableShopName: String
    let orderableShopThumbnail: String
    let estimatedTime: String
    let status: OrderInProgressStatus
    let orderTitle: String
    let totalAmount: Int
}

enum OrderInProgressType: String {
    case delivery = "DELIVERY"
    case takeout = "TAKEOUT"
}

enum OrderInProgressStatus: String {
    case confirming = "CONFIRMING"
    case cooking = "COOKING"
    case packaged = "PACKAGED"
    case pickedUp = "PICKED_UP"
    case delivering = "DELIVERING"
    case delivered = "DELIVERED"
    case canceled = "CANCELED"
}

extension OrderInProgress {
    var floatingTitleText: String {
        switch (type, status) {
        case (.delivery, .confirming):
            return "\(estimatedTime) 도착예정"
        case (.delivery, .cooking):
            return "주문 확인 중"
        case (.takeout, .cooking):
            return "\(estimatedTime) 포장 수령가능"
        default:
            return ""
        }
    }

    var floatingSubtitleText: String {
        return orderableShopName
    }
}

extension OrderInProgressStatus {
    var showEstimatedTime: Bool {
        switch self {
        case .confirming, .cooking, .packaged, .delivering:
            return true
        case .pickedUp, .delivered, .canceled:
            return false
        }
    }
}

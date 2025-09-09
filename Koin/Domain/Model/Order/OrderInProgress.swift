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
    let shopName: String
    let shopThumbnail: String
    let estimatedTime: String
    let status: OrderInProgressStatus
    let description: String
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

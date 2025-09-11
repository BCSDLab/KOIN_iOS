//
//  OrderHistory.swift
//  koin
//
//  Created by 김성민 on 9/10/25.
//

import Foundation

struct OrdersPage {
    let totalCount: Int
    let currentCount: Int
    let totalPage: Int
    let currentPage: Int
    let orders: [Order]
}

struct Order {
    let id: Int
    let paymentId: Int
    let shopId: Int
    let shopName: String
    let shopThumbnail: URL?
    let openStatus: OpenStatus
    let orderDate: Date
    let status: OrderStatus
    let orderTitle: String
    let totalAmount: Int
}

enum OrderStatus: String {
    case delivered = "DELIVERED"
    case canceled = "CANCELED"
    case confirming = "CONFIRMING"
    case cooking = "COOKING"
    case packaged = "PACKAGED"
    case pickedUp = "PICKED_UP"
    case delivering = "DELIVERING"
    case unknown = "UNKNOWN"
}

enum OpenStatus: String {
    case operating = "OPERATING"
    case closed = "CLOSED"
    case paused = "PAUSED"
    case unknown = "UNKNOWN"
}

// MARK: - Query

enum OrderHistoryPeriod {
    case none
    case last3Months
    case last6Months
    case last1Year
}

enum OrderHistoryStatus {
    case none
    case completed
    case canceled
}

enum OrderHistoryType {
    case none
    case delivery
    case takeout
}

struct OrderHistoryQuery {
    var period: OrderHistoryPeriod = .none
    var status: OrderHistoryStatus = .none
    var type: OrderHistoryType = .none
    var keyword: String = ""
}


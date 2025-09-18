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
    let orders: [OrderHistory]
}

struct OrderHistory {
    let id: Int
    let paymentId: Int
    let shopId: Int
    let shopName: String
    let shopThumbnail: URL?
    let openStatus: Bool
    let orderDate: Date
    let status: OrderStatus
    let orderTitle: String
    let totalAmount: Int
}

enum OrderStatus: String {
    case delivered = "DELIVERED"
    case canceled = "CANCELED"
    case pickedUp = "PICKED_UP"
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
    var page: Int = 1
    var size: Int = 10
}


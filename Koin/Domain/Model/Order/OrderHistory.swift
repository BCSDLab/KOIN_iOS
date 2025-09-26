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
    
    var text: String{
        switch self {
        case .delivered: return "배달완료"
        case .pickedUp: return "포장완료"
        case .canceled: return "취소완료"
        }
    }
}

extension OrderHistory {
    var isReorderable: Bool{
        (status == .delivered || status == .pickedUp) && openStatus
    }
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

extension OrderHistoryQuery {
    
    mutating func resetFilter() {
        period = .none
        status = .none
        type = .none
        page = 1
    }
    
    mutating func apply(period: OrderHistoryPeriod? = nil,
                        status: OrderHistoryStatus? = nil,
                        type: OrderHistoryType? = nil,
                        keyword: String? = nil ) {
        if let period = period { self.period = period}
        if let status = status { self.status = status}
        if let type = type { self.type = type}
        if let keyword = keyword {self.keyword = keyword}
        page = 1
    }
    
    mutating func nextPage() { page += 1 }
}

extension OrderHistoryQuery {
    var periodTitle: String {
        switch period {
        case .none: return "조회 기간"
        case .last3Months: return "최근 3개월"
        case .last6Months: return "최근 6개월"
        case .last1Year: return "최근 1년"
        }
    }
    var infoTitle: String {
        var parts: [String] = []
        switch type {
        case .delivery: parts.append("배달")
        case .takeout: parts.append("포장")
        case .none: break
        }
        switch status {
        case .completed: parts.append("완료")
        case .canceled: parts.append("취소")
        case .none: break
        }
        
        return parts.isEmpty ? "주문 상태 · 정보" : parts.joined(separator: " · ")
    }
}



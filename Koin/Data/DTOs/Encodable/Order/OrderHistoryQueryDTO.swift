//
//  OrderHistoryQueryDTO.swift
//  koin
//
//  Created by 김성민 on 9/11/25.
//

import Foundation

struct OrderHistoryQueryDTO: Encodable {
    let period: String
    let status: String
    let type: String
    let query: String
    let page: Int
    let size: Int
}

extension OrderHistoryQueryDTO {
    init(_ query: OrderHistoryQuery) {
        switch query.period {
        case .none: period = "NONE"
        case .last3Months: period = "LAST_3_MONTHS"
        case .last6Months: period = "LAST_6_MONTHS"
        case .last1Year: period = "LAST_1_YEAR"
        }

        switch query.status {
        case .none: status = "NONE"
        case .completed: status = "COMPLETED"
        case .canceled: status = "CANCELED"
        }

        switch query.type {
        case .none: type = "NONE"
        case .delivery: type = "DELIVERY"
        case .takeout: type = "TAKE_OUT"
        }
        self.query = query.keyword
        self.page = query.page
        self.size = query.size
    }

    var asParameters: [String: Any] {
        ["page": page, "size": size, "period": period, "status": status, "type": type, "query": query]
    }
}

//
//  OrderFilter.swift
//  koin
//
//  Created by 김성민 on 9/6/25.
//

import Foundation

struct OrderFilter: Equatable {
    enum Period { case threeMonths, sixMonths, oneYear }
    enum Method { case delivery, takeout }
    enum Info { case completed, canceled}
        
    var period: Period?
    var method: Method?
    var info: Info?
    static let empty = OrderFilter(period: nil, method: nil, info: nil)
}

extension OrderFilter {
    func toDomainQuery(keyword: String) -> OrderHistoryQuery {
        var query = OrderHistoryQuery()

        if let period = period {
            switch period {
            case .threeMonths: query.period = .last3Months
            case .sixMonths:   query.period = .last6Months
            case .oneYear:     query.period = .last1Year
            }
        } else {
            query.period = .none
        }
        
        if let info = info {
            switch info {
            case .completed: query.status = .completed
            case .canceled:  query.status = .canceled
            }
        } else {
            query.status = .none
        }
        
        if let method = method {
            query.type = (method == .delivery) ? .delivery : .takeout
        } else {
            query.type = .none
        }
        query.keyword = keyword
        return query
    }
}

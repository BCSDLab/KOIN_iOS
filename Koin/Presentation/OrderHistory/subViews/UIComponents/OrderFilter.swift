//
//  OrderFilter.swift
//  koin
//
//  Created by 김성민 on 9/6/25.
//

import Foundation

struct OrderFilter: Equatable {
    enum Period  { case threeMonths, sixMonths, oneYear }
    enum Method  { case delivery, takeout }
    struct Info: OptionSet {
        let rawValue: Int
        static let completed = Info(rawValue: 1 << 0)
        static let canceled  = Info(rawValue: 1 << 1)
    }
    var period: Period?
    var method: Method?
    var info: Info = []
    static let empty = OrderFilter(period: nil, method: nil, info: [])
}

extension OrderFilter {
    func toDomainQuery(keyword: String) -> OrderHistoryQuery {
        var q = OrderHistoryQuery()

        
        if let p = period {
            switch p {
            case .threeMonths: q.period = .last3Months
            case .sixMonths:   q.period = .last6Months
            case .oneYear:     q.period = .last1Year
            }
        } else {
            q.period = .none
        }
        
        let wantsCompleted = info.contains(.completed)
        let wantsCanceled  = info.contains(.canceled)
        if wantsCompleted && !wantsCanceled { q.status = .completed }
        else if wantsCanceled && !wantsCompleted { q.status = .canceled }
        else { q.status = .none }

        if let m = method {
            q.type = (m == .delivery) ? .delivery : .takeout
        } else {
            q.type = .none
        }
        q.keyword = keyword
        return q
    }
}

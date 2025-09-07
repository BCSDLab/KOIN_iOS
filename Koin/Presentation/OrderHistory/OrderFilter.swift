//
//  OrderFilter.swift
//  koin
//
//  Created by 김성민 on 9/6/25.
//

import Foundation

struct OrderFilter: Equatable {
    enum Period  { case m3, m6, y1 }
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

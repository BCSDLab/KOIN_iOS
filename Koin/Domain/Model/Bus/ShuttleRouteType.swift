//
//  ShuttleRouteType.swift
//  koin
//
//  Created by JOOMINKYUNG on 11/30/24.
//

import Foundation

enum ShuttleRouteType: String, Decodable, CaseIterable {
    case overall = "전체"
    case circular = "순환"
    case weekend = "주말"
    case weekday = "주중"
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try? container.decode(String.self)
        self = ShuttleRouteType(rawValue: rawValue ?? "") ?? .circular
    }
    
    func returnRouteColor() -> String {
        switch self {
        case .circular:
            return "4ED927"
        case .weekday:
            return "FFB443"
        default:
            return "34ADFF"
        }
    }
}

//
//  ShuttleRouteType.swift
//  koin
//
//  Created by JOOMINKYUNG on 11/30/24.
//

import Foundation

enum ShuttleRouteType: String {
    case circular = "순환"
    case weekday = "주중"
    case weekend = "주말"
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try? container.decode(String.self)
        self = ShuttleRouteType(rawValue: rawValue ?? "") ?? .circular
    }
}

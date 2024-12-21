//
//  BusType.swift
//  koin
//
//  Created by JOOMINKYUNG on 7/23/24.
//

import Foundation

enum BusType: String, Decodable, CaseIterable {
    case shuttleBus = "SHUTTLE"
    case expressBus = "EXPRESS"
    case cityBus = "CITY"
    case noValue = "ALL"
    case commuteBus = "COMMUTING"

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try? container.decode(String.self)
        self = BusType(rawValue: rawValue?.uppercased() ?? "") ?? .noValue
    }
    
    var koreanDescription: String {
        switch self {
        case .shuttleBus:
            return "셔틀버스"
        case .expressBus:
            return "대성고속"
        case .cityBus:
            return "시내버스"
        case .commuteBus:
            return "통학버스"
        case .noValue:
            return "전체 차종"
        }
    }
    
    func returnBusTypeColor() -> String {
        switch self {
        case .shuttleBus:
            return "D7FBEB"
        case .expressBus:
            return "D7E6FB"
        default:
            return "FBEBD7"
        }
    }
}

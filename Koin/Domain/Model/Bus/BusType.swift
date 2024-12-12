//
//  BusType.swift
//  koin
//
//  Created by JOOMINKYUNG on 7/23/24.
//

import Foundation
import UIKit

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
        case .noValue:
            return "전체 차종"
        case .commuteBus:
            return "통근버스"
        }
    }
    
    func returnBusTypeColor() -> UIColor {
        switch self {
        case .shuttleBus:
            return UIColor.appColor(.pastelOrange)
        case .expressBus:
            return UIColor.appColor(.pastelBlue)
        default:
            return UIColor.appColor(.pastelGreen)
        }
    }
}

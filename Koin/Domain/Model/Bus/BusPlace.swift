//
//  BusPlace.swift
//  koin
//
//  Created by JOOMINKYUNG on 7/23/24.
//

import Foundation

enum BusPlace: String, Decodable, CaseIterable {
    case koreatech = "KOREATECH"
    case station = "STATION"
    case terminal = "TERMINAL"
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = BusPlace(rawValue: rawValue) ?? .koreatech
    }
    
    var koreanDescription: String {
        switch self {
        case .koreatech:
            return "한기대"
        case .station:
            return "천안역"
        case .terminal:
            return "야우리"
        }
    }
    
    func mappingKoreanToEnglishValue(koreanDescription: String) -> BusPlace {
        switch koreanDescription {
        case "한기대":
            return .koreatech
        case "천안역":
            return .station
        case "야우리":
            return .terminal
        default:
            return .koreatech
        }
    }
}

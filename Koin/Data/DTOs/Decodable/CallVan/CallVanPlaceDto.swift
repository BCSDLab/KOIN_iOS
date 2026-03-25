//
//  CallVanPlaceDto.swift
//  koin
//
//  Created by 홍기정 on 3/15/26.
//

import Foundation

enum CallVanPlaceDto: String, Codable {
    case frontGate = "FRONT_GATE"
    case backGate = "BACK_GATE"
    case tennisCourt = "TENNIS_COURT"
    case dormitoryMain = "DORMITORY_MAIN"
    case dormitorySub = "DORMITORY_SUB"
    case terminal = "TERMINAL"
    case station = "STATION"
    case asanStation = "ASAN_STATION"
    case custom = "CUSTOM"
}

extension CallVanPlaceDto {
    init?(from model: CallVanPlace) {
        switch model {
        case .asanStation: self = .asanStation
        case .backGate: self = .backGate
        case .custom: self = .custom
        case .dormitoryMain: self = .dormitoryMain
        case .dormitorySub: self = .dormitorySub
        case .frontGate: self = .frontGate
        case .station: self = .station
        case .tennisCourt: self = .tennisCourt
        case .terminal: self = .terminal
        case .all: return nil
        }
    }
    
    func toDomain() -> CallVanPlace {
        switch self {
        case .asanStation:
            return .asanStation
        case .backGate:
            return .backGate
        case .custom:
            return .custom
        case .dormitoryMain:
            return .dormitoryMain
        case .dormitorySub:
            return .dormitorySub
        case .frontGate:
            return .frontGate
        case .station:
            return .station
        case .tennisCourt:
            return .tennisCourt
        case .terminal:
            return .terminal
        }
    }
}

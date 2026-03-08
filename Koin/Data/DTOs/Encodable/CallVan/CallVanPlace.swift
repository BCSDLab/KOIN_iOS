//
//  CallVanPlace.swift
//  koin
//
//  Created by 홍기정 on 3/6/26.
//

import Foundation

enum CallVanPlace: String, Encodable {
    case frontGate = "FRONT_GATE"
    case backGate = "BACK_GATE"
    case tennisCourt = "TENNIS_COURT"
    case dormitoryMain = "DORMITORY_MAIN"
    case dormitorySub = "DORMITORY_SUB"
    case terminal = "TERMINAL"
    case station = "STATION"
    case asanStation = "ASAN_STATION"
    case custom = "CUSTOM"
    
    var description: String {
        switch self {
        case .frontGate: return "정문"
        case .backGate: return "후문"
        case .tennisCourt: return "테니스장"
        case .dormitoryMain: return "본관동"
        case .dormitorySub: return "별관동"
        case .terminal: return "야우리"
        case .station: return "천안역"
        case .asanStation: return "천안아산역"
        case .custom: return "기타"
        }
    }
    
    init?(description: String) {
        switch description {
        case "정문": self = .frontGate
        case "후문": self = .backGate
        case "테니스장": self = .tennisCourt
        case "본관동": self = .dormitoryMain
        case "별관동": self = .dormitorySub
        case "야우리": self = .terminal
        case "천안역": self = .station
        case "천안아산역": self = .asanStation
        case "기타": self = .custom
        default: return nil
        }
    }
}

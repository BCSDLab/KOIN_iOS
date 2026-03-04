//
//  CallVanListRequest.swift
//  koin
//
//  Created by 홍기정 on 3/4/26.
//

import Foundation

struct CallVanListRequest: Encodable {
    var sort: CallVanListSort?
    var state: CallVanStateDto?
    var departure: [CallVanPlace]?
    var arrival: [CallVanPlace]?
    var departureKeyword: String?
    var arrivalKeyword: String?
    
    var title: String?
    var author: CallVanAuthor?
    var page: Int = 1
    var limit: Int = 10
    
    enum CodingKeys: String, CodingKey {
        case author
        case departure = "departures"
        case departureKeyword = "departure_keyword"
        case arrival = "arrivals"
        case arrivalKeyword = "arrival_keyword"
        case state = "statuses"
        case title
        case sort
        case page
        case limit
    }
}

enum CallVanAuthor: String, Encodable {
    case all = "ALL"
    case my = "MY"
}

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
        case .custom: return ""
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
        default: return nil
        }
    }
}

enum CallVanListSort: String, Encodable {
    case departureAsc = "DEPARTURE_ASC"
    case departureDesc = "DEPARTURE_DESC"
    case latestAsc = "LATEST_ASC"
    case latestDesc = "LATEST_DESC"
    
    var description: String {
        switch self {
        case .departureAsc: return "출발시각역순"
        case .departureDesc: return "출발시각순"
        case .latestAsc: return "과거순"
        case .latestDesc: return "최신순"
        }
    }
}

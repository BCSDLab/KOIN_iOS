//
//  CallVanListRequestDto.swift
//  koin
//
//  Created by 홍기정 on 3/4/26.
//

import Foundation

struct CallVanListRequestDto: Encodable {
    var sort: CallVanListSortDto?
    var statuses: [CallVanRecruitmentStateDto]?
    var departures: [CallVanPlaceDto]?
    var arrivals: [CallVanPlaceDto]?
    var departureKeyword: String?
    var arrivalKeyword: String?
    var title: String?
    var author: CallVanAuthorDto?
    var page: Int
    var limit: Int
    
    enum CodingKeys: String, CodingKey {
        case author, departures
        case departureKeyword = "departure_keyword"
        case arrivals
        case arrivalKeyword = "arrival_keyword"
        case statuses, title, sort, page, limit
    }
}

enum CallVanListSortDto: String, Encodable {
    case departureAsc = "DEPARTURE_ASC"
    case departureDesc = "DEPARTURE_DESC"
    case latestAsc = "LATEST_ASC"
    case latestDesc = "LATEST_DESC"
}

enum CallVanRecruitmentStateDto: String, Encodable {
    case recruiting = "RECRUITING"
    case closed = "CLOSED"
    case completed = "COMPLETED"
}

enum CallVanPlaceDto: String, Encodable {
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

enum CallVanAuthorDto: String, Encodable {
    case all = "ALL"
    case my = "MY"
}

extension CallVanListRequestDto {
    init(from model: CallVanListRequest) {
        self.sort = CallVanListSortDto(from: model.sort)
        self.statuses = {
            switch model.state {
            case .all:
                return [.recruiting, .closed]
            case .recruiting:
                return [.recruiting]
            case .closed:
                return [.closed]
            }
        }()
        self.departures = {
            if model.departure.contains(.all) {
                return nil
            } else {
                let departures = model.departure.compactMap {
                    CallVanPlaceDto(from: $0)
                }
                return departures.isEmpty ? nil : departures
            }
        }()
        self.arrivals = {
            if model.arrival.contains(.all) {
                return nil
            } else {
                let arrivals = model.arrival.compactMap {
                    CallVanPlaceDto(from: $0)
                }
                return arrivals.isEmpty ? nil : arrivals
            }
        }()
        self.departureKeyword = model.departureKeyword
        self.arrivalKeyword = model.arrivalKeyword
        self.title = model.title
        self.author = .all
        self.page = model.page
        self.limit = model.limit
    }
}

extension CallVanListSortDto {
    init(from model: CallVanListSort) {
        switch model {
        case .departureAsc:
            self = .departureAsc
        case .departureDesc:
            self = .departureDesc
        case .latestAsc:
            self = .latestAsc
        case .latestDesc:
            self = .latestDesc
        }
    }
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
}

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

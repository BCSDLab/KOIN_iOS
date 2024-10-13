//
//  NotiAgreementDTO.swift
//  koin
//
//  Created by 김나훈 on 4/18/24.
// nullable 주민경 2024/05/02

import Foundation

struct NotiAgreementDTO: Decodable {
    var isPermit: Bool?
    var subscribes: [Subscribe]?
    
    enum CodingKeys: String, CodingKey {
        case isPermit = "is_permit"
        case subscribes
    }
}

struct Subscribe: Decodable {
    let type: SubscribeType?
    let isPermit: Bool?
    let detailSubscribes: [DetailSubscribe]?
    
    enum CodingKeys: String, CodingKey {
        case type
        case isPermit = "is_permit"
        case detailSubscribes = "detail_subscribes"
    }
}

struct DetailSubscribe: Decodable {
    let detailType: DetailSubscribeType?
    let isPermit: Bool?
    
    enum CodingKeys: String, CodingKey {
        case detailType = "detail_type"
        case isPermit = "is_permit"
    }
}

enum SubscribeType: String, Codable {
    case shopEvent = "SHOP_EVENT"
    case diningSoldOut = "DINING_SOLD_OUT"
    case diningImageUpload = "DINING_IMAGE_UPLOAD"
    case articleKeyWord = "ARTICLE_KEYWORD"
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = SubscribeType(rawValue: rawValue) ?? .shopEvent
    }
}

enum DetailSubscribeType: String, Codable, CaseIterable {
    case breakfast = "BREAKFAST"
    case lunch = "LUNCH"
    case dinner = "DINNER"
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = DetailSubscribeType(rawValue: rawValue) ?? .breakfast
    }
}

//
//  DiningDTO.swift
//  Koin
//
//  Created by 김나훈 on 3/9/24.
//  Nullable 2024.04.26

import Foundation

struct DiningDTO: Decodable {
    let id: Int
    let date: String
    let type: DiningType
    let place: DiningPlace
    let priceCard, priceCash: Int?
    let kcal: Int?
    let menu: [String]?
    let createdAt, updatedAt: String
    let soldoutAt, changedAt: String?
    let imageURL: String?
    let likes: Int
    let isLiked: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, date, type, place, likes
        case priceCard = "price_card"
        case priceCash = "price_cash"
        case kcal, menu
        case imageURL = "image_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case soldoutAt = "soldout_at"
        case changedAt = "changed_at"
        case isLiked = "is_liked"
    }
    
    func toDomain() -> DiningItem {
        return .init(id: id, type: type, place: place, priceCard: priceCard, priceCash: priceCash, kcal: kcal ?? 0, menu: menu ?? [], soldoutAt: soldoutAt, changedAt: changedAt, imageUrl: imageURL, likes: likes, isLiked: isLiked, date: date
        )
    }
}

enum DiningType: String, Decodable {
    case breakfast = "BREAKFAST"
    case lunch = "LUNCH"
    case dinner = "DINNER"
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = DiningType(rawValue: rawValue) ?? .breakfast
    }
    
    var name: String {
        switch self {
        case .breakfast : "아침"
        case .lunch : "점심"
        case .dinner : "저녁"
        }
    }
}

enum DiningPlace: String, Decodable {
    case cornerA = "A코너"
    case cornerB = "B코너"
    case cornerC = "C코너"
    case special = "능수관"
    case secondCampus = "2캠퍼스"
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = DiningPlace(rawValue: rawValue) ?? .cornerA
    }
}

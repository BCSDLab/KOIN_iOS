//
//  DiningDto.swift
//  Koin
//
//  Created by 김나훈 on 3/9/24.
//  Nullable 2024.04.26

import Foundation

struct DiningDto: Decodable {
    let id: Int
    let date: String
    let type: String
    let place: String
    let priceCard, priceCash: Int?
    let kcal: Int?
    let menu: [String]?
    let createdAt, updatedAt: String
    let soldoutAt, changedAt: String?
    let imageURL: String?
    
    enum CodingKeys: String, CodingKey {
        case id, date, type, place
        case priceCard = "price_card"
        case priceCash = "price_cash"
        case kcal, menu
        case imageURL = "image_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case soldoutAt = "soldout_at"
        case changedAt = "changed_at"
    }
    
    func toDomain() -> DiningItem? {
        guard let type = DiningTypeDto(rawValue: type)?.toDomain(),
              let place = DiningPlaceDto(rawValue: place)?.toDomain() else {
            return nil
        }
        return .init(
            id: id,
            type: type,
            place: place,
            priceCard: priceCard,
            priceCash: priceCash,
            kcal: kcal ?? 0,
            menu: menu ?? [],
            soldoutAt: soldoutAt,
            changedAt: changedAt,
            imageUrl: imageURL,
            date: date
        )
    }
}

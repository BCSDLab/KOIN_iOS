//
//  StoreDTO.swift
//  Koin
//
//  Created by 김나훈 on 3/12/24.
// nullable 주민경 2024/05/02

import Foundation

struct ShopsDTO: Decodable {
    let count: Int
    var shops: [ShopDTO]?
}

extension ShopsDTO {
    func toDomain() -> [Shop] {
        return shops?.map { $0.toDomain() } ?? []
    }
}

struct ShopDTO: Decodable {
    let categoryIds: [Int]
    let delivery: Bool
    let id: Int
    let name: String
    let shopOpen: [Open]?
    let payBank, payCard: Bool
    let phone: String?
    let isEvent: Bool
    let isOpen: Bool
    let averageRate: Double
    let reviewCount: Int
    let benefitDetails: [String]?
    let benefitDetail: String?

    enum CodingKeys: String, CodingKey {
        case categoryIds = "category_ids"
        case delivery, id, name
        case shopOpen = "open"
        case payBank = "pay_bank"
        case payCard = "pay_card"
        case phone
        case isEvent = "is_event"
        case isOpen = "is_open"
        case averageRate = "average_rate"
        case reviewCount = "review_count"
        case benefitDetails = "benefit_details"
        case benefitDetail = "benefit_detail"
    }
}

extension ShopDTO {
    func toDomain() -> Shop {
        return .init(categoryIds: categoryIds, delivery: delivery, id: id, name: name, payBank: payCard, payCard: payCard, isEvent: isEvent, isOpen: isOpen, reviewCount: reviewCount, averageRate: averageRate, benefitDetails: benefitDetails ?? [], benefitDetail: benefitDetail)
    }
}

struct Open: Decodable {
    let closeTime: String?
    let closed: Bool
    let dayOfWeek: String
    let openTime: String?

    enum CodingKeys: String, CodingKey {
        case closeTime = "close_time"
        case closed
        case dayOfWeek = "day_of_week"
        case openTime = "open_time"
    }
}

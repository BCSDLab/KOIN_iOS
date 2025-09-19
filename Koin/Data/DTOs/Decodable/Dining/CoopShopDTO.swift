//
//  CoopShopDto.swift
//  koin
//
//  Created by 김나훈 on 7/19/24.
//

import Foundation

struct CoopShopDto: Decodable {
    let id: Int
    let name, semester: String
    let opens: [CoopOpenDto]?
    let phone, location: String
    let remarks: String?
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, semester, opens, phone, location, remarks
        case updatedAt = "updated_at"
    }
    
    func toDomain() -> CoopShopData {
        return .init(location: location, phone: phone, remarks: remarks ?? "", name: name, semester: semester, opens: opens ?? [], updatedAt: formatUpdatedAt(updatedAt))
    }
    
    private func formatUpdatedAt(_ updatedAt: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = dateFormatter.date(from: updatedAt) else {
            return updatedAt
        }
        return date.formatDateToCustom()
    }
}

struct CoopOpenDto: Decodable {
    let dayOfWeek: DayOfWeek
    let type: MealType
    let openTime, closeTime: String
    
    enum CodingKeys: String, CodingKey {
        case dayOfWeek = "day_of_week"
        case type
        case openTime = "open_time"
        case closeTime = "close_time"
    }
}

enum DayOfWeek: String, Decodable {
    case weekday = "평일"
    case weekend = "주말"
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = DayOfWeek(rawValue: rawValue) ?? .weekday
    }
}

enum MealType: String, Decodable {
    case breakfast = "아침"
    case lunch = "점심"
    case dinner = "저녁"
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = MealType(rawValue: rawValue) ?? .breakfast
    }
}

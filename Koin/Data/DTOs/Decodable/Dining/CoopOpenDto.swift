//
//  CoopOpenDto.swift
//  koin
//
//  Created by 김나훈 on 7/19/24.
//

import Foundation

struct CoopOpenDto: Decodable {
    let dayOfWeek: String
    let type: String
    let openTime, closeTime: String

    enum CodingKeys: String, CodingKey {
        case dayOfWeek = "day_of_week"
        case type
        case openTime = "open_time"
        case closeTime = "close_time"
    }

    func toDomain() -> CoopOpen? {
        guard let dayOfWeek = DayOfWeekDto(rawValue: dayOfWeek)?.toDomain(),
              let type = MealTypeDto(rawValue: type)?.toDomain() else {
            return nil
        }
        return .init(
            dayOfWeek: dayOfWeek,
            type: type,
            openTime: openTime,
            closeTime: closeTime
        )
    }
}

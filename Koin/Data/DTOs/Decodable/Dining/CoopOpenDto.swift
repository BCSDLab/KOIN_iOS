//
//  CoopOpenDto.swift
//  koin
//
//  Created by 김나훈 on 7/19/24.
//

import Foundation

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

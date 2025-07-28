//
//  SendVerificationCodeDTO.swift
//  koin
//
//  Created by 이은지 on 4/28/25.
//

import Foundation

struct SendVerificationCodeDTO: Decodable {
    let target: String
    let totalCount, remainingCount, currentCount: Int

    enum CodingKeys: String, CodingKey {
        case target
        case totalCount = "total_count"
        case remainingCount = "remaining_count"
        case currentCount = "current_count"
    }
}

//
//  UserTypeResponse.swift
//  koin
//
//  Created by 김나훈 on 1/16/25.
//

import Foundation

struct UserTypeResponse: Codable {
    let userType: UserType

    enum CodingKeys: String, CodingKey {
        case userType = "user_type"
    }
}

enum UserType: String, Codable {
    case student = "STUDENT"
    case admin = "ADMIN"
    case coop = "COOP"
    case council = "COUNCIL"
    case general = "GENERAL"
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = UserType(rawValue: rawValue) ?? .student
    }
}

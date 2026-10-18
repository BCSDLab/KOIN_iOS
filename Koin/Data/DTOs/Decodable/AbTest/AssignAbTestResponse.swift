//
//  AssignAbTestResponse.swift
//  koin
//
//  Created by 김나훈 on 9/23/24.
//

import Foundation

struct AssignAbTestResponse: Decodable {
    let variableName: UserAssignType
    let accessHistoryId: Int
    
    enum CodingKeys: String, CodingKey {
        case variableName = "variable_name"
        case accessHistoryId = "access_history_id"
    }
}

enum UserAssignType: String, Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        if let assignType = UserAssignType(rawValue: rawValue) {
            self = assignType
        } else {
            throw ErrorResponse.unknownUserAssignType
        }
    }
}

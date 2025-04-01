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
    case a = "A", b = "B", c = "C", d = "D", e = "E"
    case shareOriginal = "share_original"
    case shareNew = "share_new"
    case mainDiningOriginal = "main_dining_original"
    case mainDiningNew = "main_dining_new"
    case bannerOriginal = "banner_original"
    case bannerNew = "banner_new"
    case callNumber = "call_number"
    case callFloating = "call_floating"
    case bottomBanner = "bottom_banner"
    case centerBanner = "center_banner"
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = UserAssignType(rawValue: rawValue) ?? .a
    }
}

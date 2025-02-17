//
//  ChatDetailDTO.swift
//  koin
//
//  Created by 김나훈 on 2/18/25.
//

import Foundation

struct ChatDetailDTO: Codable {
    let userId: Int
    let userNickname, content, timestamp: String
    let isImage: Bool

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case userNickname = "user_nickname"
        case content, timestamp
        case isImage = "is_image"
    }
}


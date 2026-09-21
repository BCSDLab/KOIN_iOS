//
//  LostItemChatDetailDto.swift
//  koin
//
//  Created by 김나훈 on 2/18/25.
//

import Foundation

struct LostItemChatDetailDto: Codable {
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

extension LostItemChatDetailDto {
    func toDomain(currentUserId: Int) -> LostItemChatMessage {
        return LostItemChatMessage(
            senderNickname: userNickname,
            content: content,
            timestamp: timestamp,
            isImage: isImage,
            isMine: userId == currentUserId, chatDateInfo: timestamp.toLostItemChatDateInfo()
        )
    }
}

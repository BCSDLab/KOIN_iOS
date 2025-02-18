//
//  CreateCharRoomResponse.swift
//  koin
//
//  Created by 김나훈 on 2/18/25.
//

import Foundation

struct CreateChatRoomResponse: Decodable {
    let articleId: Int
    let chatRoomId: Int
    let userId: Int
    let articleTitle: String
    let chatPartnerProfileImage: String?
    enum CodingKeys: String, CodingKey {
        case articleId = "article_id"
        case chatRoomId = "chat_room_id"
        case userId = "user_id"
        case articleTitle = "article_title"
        case chatPartnerProfileImage = "chat_partner_profile_image"
    }
}

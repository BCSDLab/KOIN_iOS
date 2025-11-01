//
//  ChatRoomDto.swift
//  koin
//
//  Created by 김나훈 on 2/18/25.
//

import Foundation

struct ChatRoomDto: Codable {
    let articleTitle, recentMessageContent: String
    let lostItemImageUrl: String?
    let unreadMessageCount: Int
    let lastMessageAt: String
    let articleId, chatRoomId: Int
    
    enum CodingKeys: String, CodingKey {
        case articleTitle = "article_title"
        case recentMessageContent = "recent_message_content"
        case lostItemImageUrl = "lost_item_image_url"
        case unreadMessageCount = "unread_message_count"
        case lastMessageAt = "last_message_at"
        case articleId = "article_id"
        case chatRoomId = "chat_room_id"
    }
}
extension ChatRoomDto {
    func toDomain() -> ChatRoomItem {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return ChatRoomItem(
            articleTitle: articleTitle,
            recentMessageContent: recentMessageContent,
            lostItemImageUrl: lostItemImageUrl,
            unreadMessageCount: unreadMessageCount, lastMessageAt: lastMessageAt,
            chatDateInfo: lastMessageAt.toChatDateInfo(),
            articleId: articleId,
            chatRoomId: chatRoomId
        )
    }
}

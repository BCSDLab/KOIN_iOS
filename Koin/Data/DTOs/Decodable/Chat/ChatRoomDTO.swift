//
//  ChatRoomDTO.swift
//  koin
//
//  Created by 김나훈 on 2/18/25.
//

import Foundation

struct ChatRoomDTO: Codable {
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
extension ChatRoomDTO {
    func toDomain() -> ChatRoomItem {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let date = formatter.date(from: lastMessageAt) ?? Date() // 변환 실패 시 현재 시간 사용
        return ChatRoomItem(
            articleTitle: articleTitle,
            recentMessageContent: recentMessageContent,
            lostItemImageUrl: lostItemImageUrl,
            unreadMessageCount: unreadMessageCount,
            lastMessageAt: date,
            year: date.year,
            month: date.month,
            day: date.day,
            hour: date.hour,
            minute: date.minute,
            second: date.second,
            articleId: articleId,
            chatRoomId: chatRoomId
        )
    }
}

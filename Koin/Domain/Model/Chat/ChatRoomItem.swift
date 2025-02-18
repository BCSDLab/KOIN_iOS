//
//  ChatRoomItem.swift
//  koin
//
//  Created by 김나훈 on 2/18/25.
//

import Foundation

struct ChatRoomItem {
    let articleTitle: String
    let recentMessageContent: String
    let lostItemImageUrl: String?
    let unreadMessageCount: Int
    let lastMessageAt: Date
    let year: Int
    let month: Int
    let day: Int
    let hour: Int
    let minute: Int
    let second: Int
    let articleId: Int
    let chatRoomId: Int
}

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
    let lastMessageAt: String
    let chatDateInfo: ChatDateInfo
    let articleId: Int
    let chatRoomId: Int
}

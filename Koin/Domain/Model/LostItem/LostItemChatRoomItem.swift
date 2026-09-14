//
//  LostItemChatRoomItem.swift
//  koin
//
//  Created by 김나훈 on 2/18/25.
//

import Foundation

struct LostItemChatRoomItem {
    let articleTitle: String
    let recentMessageContent: String
    let lostItemImageUrl: String?
    let unreadMessageCount: Int
    let lastMessageAt: String
    let chatDateInfo: LostItemChatDateInfo
    let articleId: Int
    let chatRoomId: Int
}

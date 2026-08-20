//
//  LostItemChatHistoryData.swift
//  koin
//
//  Created by 김나훈 on 2/20/25.
//

import Foundation

struct LostItemChatMessage {
    let senderNickname: String
    let content: String
    let timestamp: String
    let isImage: Bool
    let isMine: Bool
    let chatDateInfo: LostItemChatDateInfo
}

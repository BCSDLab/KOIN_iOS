//
//  RecruitChatMessage.swift
//  koin
//
//  Created by 홍기정 on 9/28/26.
//

import Foundation

struct RecruitChatMessage {
    let messageId: Int
    let userId: Int
    let userNickname: String
    let content: String
    let timestamp: Date
    let isImage: Bool
    let unreadCount: Int
    let isMine: Bool
    let showProfile: Bool
    let profileImage: ImageAsset?
    
    var displayTime: String {
        timestamp.formatDateToHHMM(isHH: true)
    }
}

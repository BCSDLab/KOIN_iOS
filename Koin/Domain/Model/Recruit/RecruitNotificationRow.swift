//
//  RecruitNotificationRow.swift
//  koin
//
//  Created by 홍기정 on 8/29/26.
//

import Foundation

struct RecruitNotificationRow {
    let id: Int
    let recruitmentId: Int
    let chatRoomId: Int
    let roomType: RecruitChatRoomType
    let applicationId: Int?

    let type: RecruitNotificationType

    let title: String
    let content: String
    let dateText: String
    var isRead: Bool
}

enum RecruitNotificationType {
    case chat
    case newApplicant
    case `default`
}

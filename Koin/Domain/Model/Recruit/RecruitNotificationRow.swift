//
//  RecruitNotificationRow.swift
//  koin
//
//  Created by 홍기정 on 8/29/26.
//

import Foundation

struct RecruitNotificationRow {
    let id: Int
    let type: RecruitNotificationType
    let targetType: RecruitNotificationTargetType
    let recruitmentId: Int
    let applicationId: Int?
    let chatRoomId: Int?
    let senderNickname: String?
    let messagePreview: String
    let createdAt: Date?
    var isRead: Bool
}

enum RecruitNotificationType {
    case newApplication
    case applicationAccepted
    case applicationRejected
    case recruitmentClosed
    case recruitmentDeleted
    case newChatMessage
}

enum RecruitNotificationTargetType {
    case applicantManagement
    case chatRoom
    case myApplications
    case none
}

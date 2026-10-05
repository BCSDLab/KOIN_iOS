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

enum RecruitNotificationType: String {
    case newApplication = "new_application"
    case applicationAccepted = "application_accepted"
    case applicationRejected = "application_rejected"
    case recruitmentClosed = "recruitment_closed"
    case recruitmentDeleted = "recruitment_deleted"
    case newChatMessage = "new_chat_message"
}

enum RecruitNotificationTargetType {
    case applicantManagement
    case chatRoom
    case myApplications
    case none
}

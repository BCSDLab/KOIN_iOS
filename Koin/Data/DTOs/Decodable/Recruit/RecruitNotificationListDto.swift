//
//  RecruitNotificationListDto.swift
//  koin
//
//  Created by 홍기정 on 10/5/26.
//

import Foundation

struct RecruitNotificationListDto: Decodable {
    let notifications: [RecruitNotificationRowDto]
    let totalPage: Int
    let currentPage: Int

    enum CodingKeys: String, CodingKey {
        case notifications
        case totalPage = "total_page"
        case currentPage = "current_page"
    }
}

struct RecruitNotificationRowDto: Decodable {
    let id: Int
    let type: String
    let targetType: String
    let recruitmentId: Int
    let applicationId: Int?
    let chatRoomId: Int?
    let senderNickname: String?
    let messagePreview: String
    let isRead: Bool
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, type
        case targetType = "target_type"
        case recruitmentId = "recruitment_id"
        case applicationId = "application_id"
        case chatRoomId = "chat_room_id"
        case senderNickname = "sender_nickname"
        case messagePreview = "message_preview"
        case isRead = "is_read"
        case createdAt = "created_at"
    }
}

enum RecruitNotificationTypeDto: String {
    case newApplication = "NEW_APPLICATION"
    case applicationAccepted = "APPLICATION_ACCEPTED"
    case applicationRejected = "APPLICATION_REJECTED"
    case recruitmentClosed = "RECRUITMENT_CLOSED"
    case recruitmentDeleted = "RECRUITMENT_DELETED"
    case newChatMessage = "NEW_CHAT_MESSAGE"
}

enum RecruitNotificationTargetTypeDto: String {
    case applicantManagement = "APPLICANT_MANAGEMENT"
    case chatRoom = "CHAT_ROOM"
    case myApplications = "MY_APPLICATIONS"
    case none = "NONE"
}

extension RecruitNotificationListDto {
    func toDomain() -> RecruitNotificationList {
        return RecruitNotificationList(
            notifications: notifications.compactMap { $0.toDomain() },
            totalPage: totalPage,
            currentPage: currentPage
        )
    }
}

extension RecruitNotificationRowDto {
    func toDomain() -> RecruitNotificationRow? {
        guard let type = RecruitNotificationTypeDto(rawValue: type) else {
            return nil
        }
        let targetType = RecruitNotificationTargetTypeDto(rawValue: targetType) ?? .none
        let createdAtFormatter = DateFormatter().then {
            $0.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            $0.locale = Locale(identifier: "en_US_POSIX")
            $0.calendar = Calendar(identifier: .gregorian)
            $0.timeZone = TimeZone(identifier: "Asia/Seoul")
        }
        return RecruitNotificationRow(
            id: id,
            type: type.toDomain(),
            targetType: targetType.toDomain(),
            recruitmentId: recruitmentId,
            applicationId: applicationId,
            chatRoomId: chatRoomId,
            senderNickname: senderNickname,
            messagePreview: messagePreview,
            createdAt: createdAtFormatter.date(from: String(createdAt.prefix(19))),
            isRead: isRead
        )
    }
}

extension RecruitNotificationTypeDto {
    func toDomain() -> RecruitNotificationType {
        switch self {
        case .newApplication:
            return .newApplication
        case .applicationAccepted:
            return .applicationAccepted
        case .applicationRejected:
            return .applicationRejected
        case .recruitmentClosed:
            return .recruitmentClosed
        case .recruitmentDeleted:
            return .recruitmentDeleted
        case .newChatMessage:
            return .newChatMessage
        }
    }
}

extension RecruitNotificationTargetTypeDto {
    func toDomain() -> RecruitNotificationTargetType {
        switch self {
        case .applicantManagement:
            return .applicantManagement
        case .chatRoom:
            return .chatRoom
        case .myApplications:
            return .myApplications
        case .none:
            return .none
        }
    }
}

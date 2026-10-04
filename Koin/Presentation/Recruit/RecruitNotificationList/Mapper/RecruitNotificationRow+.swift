//
//  RecruitNotificationRow+.swift
//  koin
//
//  Created by 홍기정 on 8/30/26.
//

import Foundation

extension RecruitNotificationRow {
    var icon: ImageAsset {
        switch type {
        case .newChatMessage: ImageAsset.recruitNotificationChat
        default: ImageAsset.recruitNotificationMember
        }
    }
    
    var title: String {
        switch type {
        case .newApplication:
            return "팀원모집 새로운 지원자"
        case .applicationAccepted:
            return "팀원모집 지원 승인"
        case .applicationRejected:
            return "팀원모집 지원 거절"
        case .recruitmentClosed:
            return "팀원모집 모집 마감"
        case .recruitmentDeleted:
            return "팀원모집 모집글 삭제"
        case .newChatMessage:
            return "팀원모집 \(senderNickname ?? "익명")님의 메시지"
        }
    }
    
    var dateText: String {
        guard let createdAt else {
            return ""
        }
        return NotificationHistoryItem.dateText(for: createdAt)
    }
    
    func toNotificationRowModel() -> NotificationRowModel {
        NotificationRowModel(
            id: "\(id)",
            isRead: isRead,
            icon: icon,
            title: title,
            content: messagePreview,
            dateText: dateText
        )
    }
}

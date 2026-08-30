//
//  RecruitNotification+.swift
//  koin
//
//  Created by 홍기정 on 8/30/26.
//

import Foundation

extension RecruitNotification {
    var icon: ImageAsset {
        switch type {
        case .chat: ImageAsset.recruitNotificationChat
        default: ImageAsset.recruitNotificationMember
        }
    }
    
    func toNotificationRowModel() -> NotificationRowModel {
        NotificationRowModel(
            id: "\(id)",
            isRead: isRead,
            icon: icon,
            title: title,
            content: content,
            dateText: dateText
        )
    }
}

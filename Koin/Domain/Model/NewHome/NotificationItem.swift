//
//  NotificationItem.swift
//  koin
//
//  Created by 홍기정 on 6/3/26.
//

import Foundation

struct NotificationItem {
    let id: String
    let isRead: Bool
    let icon: ImageAsset
    let appPath: AppPath
    let uri: String?
    let title: String
    let content: String
    let dateText: String
    
    init(
        id: String,
        isRead: Bool,
        icon: ImageAsset,
        appPath: AppPath,
        uri: String?,
        title: String,
        content: String,
        dateText: String
    ) {
        self.id = id
        self.isRead = isRead
        self.icon = icon
        self.appPath = appPath
        self.uri = uri
        self.title = title
        self.content = content
        self.dateText = dateText
    }
}

extension NotificationItem {
    
    init?(from record: NotificationRecord) {
        guard let appPath = AppPath(rawValue: record.category),
              let icon = NotificationItem.icon(for: appPath) else {
            return nil
        }
        self.id = record.messageId
        self.isRead = record.isRead
        self.icon = icon
        self.appPath = appPath
        self.uri = record.schemeUri
        self.title = record.title
        self.content = record.body
        self.dateText = NotificationItem.dateText(for: record.createdAt)
    }
    
    static func icon(for appPath: AppPath) -> ImageAsset? {
        switch appPath {
        case .shop:
            return ImageAsset.notificationShop
        case .dining:
            return ImageAsset.notificationDining
        case .keyword:
            return ImageAsset.notificationLostItem
        case .chat:
            return ImageAsset.notificationChat
        case .callvan:
            return ImageAsset.notificationCallVan
        case .callvanChat:
            return ImageAsset.notificationChat
        default:
            return nil
        }
    }
    
    static func dateText(for createdAt: Date) -> String {
        let now = Date()
        let compareComponents = Calendar.current.dateComponents(
            [.day, .hour, .minute],
            from: createdAt,
            to: now
        )
        
        if let day = compareComponents.day, 1 <= day {
            return "\(day)일 전"
        }
        if let hour = compareComponents.hour, 1 <= hour {
            return "\(hour)시간 전"
        }
        if let minute = compareComponents.minute, 1 <= minute {
            return "\(minute)분 전"
        }
        return "지금"
    }
}

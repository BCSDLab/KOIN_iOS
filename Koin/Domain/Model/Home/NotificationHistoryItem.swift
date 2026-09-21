//
//  NotificationHistoryItem.swift
//  koin
//
//  Created by 홍기정 on 6/3/26.
//

import Foundation

struct NotificationHistoryItem {
    let id: String
    var isRead: Bool
    let icon: ImageAsset
    let appPath: AppPath
    let uri: String?
    let title: String
    let content: String
    let dateText: String
}

extension NotificationHistoryItem {
    var logValue: String? {
        switch appPath {
        case .shop:
            return "주변상점"
        case .dining:
            return "식단"
        case .keyword:
            return "키워드알림"
        case .chat:
            return "분실물 채팅"
        case .callvan:
            return "콜밴팟"
        case .callvanChat:
            return "콜밴팟 채팅"
        default:
            return nil
        }
    }

    init?(from record: NotificationHistoryRecord) {
        guard let icon = NotificationHistoryItem.icon(for: record.category) else {
            return nil
        }
        self.id = record.messageId
        self.isRead = record.isRead
        self.icon = icon
        self.appPath = record.category
        self.uri = record.schemeUri
        self.title = record.title
        self.content = record.body
        self.dateText = NotificationHistoryItem.dateText(for: record.createdAt)
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

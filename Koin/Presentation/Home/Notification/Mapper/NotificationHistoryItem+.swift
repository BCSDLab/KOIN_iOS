//
//  NotificationHistoryItem+.swift
//  koin
//
//  Created by 홍기정 on 8/19/26.
//

extension NotificationHistoryItem {
    func toNotificationRowModel() -> NotificationRowModel {
        NotificationRowModel(
            id: id,
            isRead: isRead,
            icon: icon,
            title: title,
            content: content,
            dateText: dateText
        )
    }
}

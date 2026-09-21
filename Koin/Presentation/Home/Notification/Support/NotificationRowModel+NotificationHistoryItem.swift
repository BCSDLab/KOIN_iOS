//
//  NotificationRowModel+NotificationHistoryItem.swift
//  koin
//
//  Created by 홍기정 on 8/19/26.
//

extension NotificationRowModel {
    init(from item: NotificationHistoryItem) {
        self.init(
            id: item.id,
            isRead: item.isRead,
            icon: item.icon,
            title: item.title,
            content: item.content,
            dateText: item.dateText
        )
    }
}

//
//  RecruitNotificationList.swift
//  koin
//
//  Created by 홍기정 on 8/29/26.
//

import Foundation

struct RecruitNotificationList {
    var notifications: [RecruitNotification]
}

extension RecruitNotificationList {
    var hasUnread: Bool {
        !notifications.filter({ !$0.isRead }).isEmpty
    }
    
    mutating func delete(id: Int) {
        notifications = notifications.filter { $0.id != id }
    }
    
    mutating func deleteAll() {
        notifications.removeAll()
    }
    
    mutating func markAsRead(id: Int) {
        if let index = notifications.firstIndex(where: { $0.id == id }) {
            var notification = notifications[index]
            notification.isRead = true
            notifications[index] = notification
        }
    }
    
    mutating func markAllAsRead() {
        for index in notifications.indices {
            notifications[index].isRead = true
        }
    }
}

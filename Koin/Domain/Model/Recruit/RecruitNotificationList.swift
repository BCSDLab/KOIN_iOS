//
//  RecruitNotificationList.swift
//  koin
//
//  Created by 홍기정 on 8/29/26.
//

import Foundation

struct RecruitNotificationList {
    let notifications: [RecruitNotification]
}

extension RecruitNotificationList {
    var hasUnread: Bool {
        !notifications.filter({ !$0.isRead }).isEmpty
    }
}

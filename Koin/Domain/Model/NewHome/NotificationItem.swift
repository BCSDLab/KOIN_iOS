//
//  NotificationItem.swift
//  koin
//
//  Created by 홍기정 on 6/3/26.
//

import Foundation

struct NotificationItem {
    let id: Int
    let iconType: NotificationIconType
    let title: String
    let content: String
    let secondaryContent: String?
    let dateText: String
    let badgeText: String?

    init(
        id: Int,
        iconType: NotificationIconType,
        title: String,
        content: String,
        secondaryContent: String? = nil,
        dateText: String,
        badgeText: String?
    ) {
        self.id = id
        self.iconType = iconType
        self.title = title
        self.content = content
        self.secondaryContent = secondaryContent
        self.dateText = dateText
        self.badgeText = badgeText
    }
}

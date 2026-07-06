//
//  NotificationItem.swift
//  koin
//
//  Created by 홍기정 on 6/3/26.
//

import Foundation

struct NotificationItem {
    let id: Int
    let isRead: Bool
    let icon: ImageAsset
    let appPath: AppPath
    let uri: String?
    let title: String
    let content: String
    let dateText: String
    
    init(
        id: Int,
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

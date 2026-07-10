//
//  NotificationRecord.swift
//  koin
//
//  Created by 홍기정 on 7/6/26.
//

import SwiftData
import Foundation

@Model
final class NotificationRecord {
    var body: String
    var title: String
    var category: AppPath
    var schemeUri: String
    
    @Attribute(.unique)
    var messageId: String
    
    var isRead: Bool = false
    var createdAt: Date = Date()
    
    init(
        body: String,
        title: String,
        category: AppPath,
        schemeUri: String,
        messageId: String
    ) {
        self.body = body
        self.title = title
        self.category = category
        self.schemeUri = schemeUri
        self.messageId = messageId
    }
}

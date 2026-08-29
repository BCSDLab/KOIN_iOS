//
//  RecruitNotification.swift
//  koin
//
//  Created by 홍기정 on 8/29/26.
//

import Foundation

struct RecruitNotification {
    let id: Int
    let chatRoomId: Int
    
    let type: RecruitNotificationType
    
    let title: String
    let description: String
    let time: String
    let isRead: Bool
}

enum RecruitNotificationType {
    case chat
    case newApplicant
    case `default`
}

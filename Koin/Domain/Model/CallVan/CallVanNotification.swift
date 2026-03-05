//
//  CallVanNotification.swift
//  koin
//
//  Created by 홍기정 on 3/4/26.
//

import UIKit

struct CallVanNotification {
    let id: Int
    let postId: Int
    let type: CallVanNotificationType
    let isRead: Bool
    let title: String
    let description: String
    let currentParticipants: Int
    let maxParticipants: Int
    let messagePreview: String
    
    let titleTextColor: UIColor
    let descriptionTextColor: UIColor
    let messagePreviewTextColor: UIColor
    
    init(id: Int, postId: Int, type: CallVanNotificationType, isRead: Bool, description: String, currentParticipants: Int, maxParticipants: Int, messagePreview: String) {
        self.id = id
        self.postId = postId
        self.type = type
        self.isRead = isRead
        self.title = type.rawValue
        self.description = description
        self.currentParticipants = currentParticipants
        self.maxParticipants = maxParticipants
        self.messagePreview = messagePreview
        self.titleTextColor = isRead ? UIColor.appColor(.neutral500) : UIColor.appColor(.neutral800)
        self.descriptionTextColor = isRead ? UIColor.appColor(.neutral500) : UIColor.appColor(.new500)
        self.messagePreviewTextColor = isRead ? UIColor.appColor(.neutral500) : UIColor.appColor(.neutral600)
    }
}

enum CallVanNotificationType: String {
    case recruitmentCompleted = "콜밴팟 인원 모집 완료"
    case newMessage = "새 메시지 도착"
    case paritipantJoined = "콜밴팟 인원 참여"
    case departureUpcoming = "콜밴팟 출발 시각 임박"
}

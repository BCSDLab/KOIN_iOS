//
//  CallVanNotificationDto.swift
//  koin
//
//  Created by 홍기정 on 3/4/26.
//

import Foundation

struct CallVanNotificationDto: Decodable {
    let id: Int
    let isRead: Bool
    let createdAt: String
    
    let type: CallVanNotificationTypeDto
    let messagePreview: String?
    let senderNickname: String?
    let joinedMemberNickname: String?
    
    let postId: Int
    let departure: String
    let arrival: String
    let departureDate: String
    let departureTime: String
    
    let currentParticipants: Int
    let maxParticipants: Int
    
    enum CodingKeys: String, CodingKey {
        case id, type
        case messagePreview = "message_preview"
        case isRead = "is_read"
        case createdAt = "created_at"
        case postId = "post_id"
        case departure, arrival
        case departureDate = "departure_date"
        case departureTime = "departure_time"
        case currentParticipants = "current_participants"
        case maxParticipants = "max_participants"
        case senderNickname = "sender_nickname"
        case joinedMemberNickname = "joined_member_nickname"
    }
}

enum CallVanNotificationTypeDto: String, Decodable {
    case recruitmentCompleted = "RECRUITMENT_COMPLETE"
    case newMessage = "NEW_MESSAGE"
    case paritipantJoined = "PARTICIPANT_JOINED"
    case departureUpcoming = "DEPARTURE_UPCOMING"
}

extension CallVanNotificationDto {
    
    func toDomain() -> CallVanNotification {
        return CallVanNotification(id: id, postId: postId, type: type.toDomain(), isRead: isRead,
                                   description: description(departureDate, departureTime, departure, arrival),
                                   currentParticipants: currentParticipants, maxParticipants: maxParticipants,
                                   messagePreview: messagePreview(type, messagePreview, senderNickname, joinedMemberNickname))
    }
    
    func description(_ departureDate: String, _ departureTime: String, _ departure: String, _ arrival: String) -> String {
        var dateString: String
        
        let inputFormatter = DateFormatter().then {
            $0.dateFormat = "yyyy-MM-dd"
        }
        let outputFormatter = DateFormatter().then {
            $0.dateFormat = "MM.dd(E)"
        }
        if let date = inputFormatter.date(from: departureDate) {
            dateString = outputFormatter.string(from: date)
        } else {
            dateString = "DATE"
        }
        
        return "\(dateString) \(departureTime) \(departure) - \(arrival)"
    }
    
    func messagePreview(
        _ type: CallVanNotificationTypeDto,
        _ messagePreview: String?,
        _ senderNickname: String?,
        _ joinedMemberNickname: String?
    ) -> String {
        switch type {
        case .recruitmentCompleted:
            if let messagePreview {
                return messagePreview
            } else {
                return "recruitmentCompleted"
            }
        case .newMessage:
            if let senderNickname, let messagePreview {
                return "\(senderNickname): \(messagePreview)"
            } else {
                return "newMessage"
            }
        case .paritipantJoined:
            if let joinedMemberNickname {
                return "\(joinedMemberNickname)님이 콜밴팟에 참여했어요."
            } else {
                return "paritipantJoined"
            }
        case .departureUpcoming:
            return "해당 콜밴팟 출발 시간이 30분 남았어요."
        }
    }
}

extension CallVanNotificationTypeDto {
    
    func toDomain() -> CallVanNotificationType {
        switch self {
        case .departureUpcoming:
            return .departureUpcoming
        case .newMessage:
            return .newMessage
        case .paritipantJoined:
            return .paritipantJoined
        case .recruitmentCompleted:
            return .recruitmentCompleted
        }
    }
}

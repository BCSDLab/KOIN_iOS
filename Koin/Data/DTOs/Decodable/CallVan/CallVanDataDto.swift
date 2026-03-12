//
//  CallVanDataDto.swift
//  koin
//
//  Created by 홍기정 on 3/10/26.
//

import UIKit

struct CallVanDataDto: Decodable {
    let id: Int
    let title: String
    let departure: String
    let arrival: String
    let departureDate: String
    let departureTime: String
    let currentParticipants: Int
    let maxParticipants: Int
    let status: CallVanStateDto
    let participants: [CallVanParticipantDto]

    enum CodingKeys: String, CodingKey {
        case id, title, departure, arrival
        case departureDate = "departure_date"
        case departureTime = "departure_time"
        case currentParticipants = "current_participants"
        case maxParticipants = "max_participants"
        case status, participants
    }
}

struct CallVanParticipantDto: Decodable {
    let userId: Int
    let nickname: String
    let isMe: Bool

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case nickname
        case isMe = "is_me"
    }
}

extension CallVanDataDto {
    
    func toDomain() -> CallVanData {
        let profileImages: [UIImage?] = [
            UIImage.appImage(asset: .callVanProfile0),
            UIImage.appImage(asset: .callVanProfile1),
            UIImage.appImage(asset: .callVanProfile2),
            UIImage.appImage(asset: .callVanProfile3),
            UIImage.appImage(asset: .callVanProfile4),
            UIImage.appImage(asset: .callVanProfile5),
            UIImage.appImage(asset: .callVanProfile6),
            UIImage.appImage(asset: .callVanProfile7)
        ]
        var userIdIndex: [Int: Int] = [:]
        var currentIndex = 0
        var paritipantdtos = participants
        var pariticipants: [CallVanParticipant] = []
        if let me = paritipantdtos.first(where: { $0.isMe }) {
            pariticipants.append(CallVanParticipant(userId: me.userId, nickname: me.nickname + " (나)", isMe: true, index: -1, profileImage: UIImage.appImage(asset: .callVanProfileMine)))
            paritipantdtos = paritipantdtos.filter { !$0.isMe }
        }
        pariticipants.append(contentsOf:
            paritipantdtos.map {
                let index: Int
                if let validIndex = userIdIndex[$0.userId] {
                    index = validIndex
                } else {
                    userIdIndex[$0.userId] = currentIndex
                    index = currentIndex
                    currentIndex = min(currentIndex+1, 7)
                }
                return CallVanParticipant(userId: $0.userId, nickname: $0.nickname, isMe: false, index: index, profileImage: profileImages[index])
            }
        )
        
        return CallVanData(
            id: id,
            departure: "출발: \(departure)",
            arrival: "도착: \(arrival)",
            dateTime: dateTime(departureDate: departureDate, departureTime: departureTime),
            currentParticipants: currentParticipants,
            maxParticipants: maxParticipants,
            participants: pariticipants
        )
    }
    
    private func dateTime(departureDate: String, departureTime: String) -> String {
        let formatter = DateFormatter()
        let date = {
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.locale = Locale(identifier: "ko_KR")
            if let date = formatter.date(from: departureDate) {
                formatter.dateFormat = "MM.dd (a)"
                return formatter.string(from: date)
            } else {
                return departureDate
            }
        }()
        return "\(date) \(departureTime)"
    }
}

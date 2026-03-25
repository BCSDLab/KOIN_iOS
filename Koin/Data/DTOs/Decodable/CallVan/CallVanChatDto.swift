//
//  CallVanChatDto.swift
//  koin
//
//  Created by 홍기정 on 3/8/26.
//

import UIKit

struct CallVanChatDto: Decodable {
    let roomName: String
    let messages: [CallVanChatMessageDto]

    enum CodingKeys: String, CodingKey {
        case roomName = "room_name"
        case messages
    }
}

struct CallVanChatMessageDto: Decodable {
    let userId: Int
    let senderNickname: String
    let content: String
    let date: String
    let time: String
    let isImage: Bool
    let isLeftUser: Bool
    let isMine: Bool

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case senderNickname = "sender_nickname"
        case content, date, time
        case isImage = "is_image"
        case isLeftUser = "is_left_user"
        case isMine = "is_mine"
    }
}

extension CallVanChatDto {
    
    func toDomain() -> CallVanChat {
        
        let inputDateFormatter = DateFormatter()
        inputDateFormatter.dateFormat = "yyyy. MM. dd"
        let outputDateFormatter = DateFormatter()
        outputDateFormatter.dateFormat = "yyyy년 M월 d일"
        
        let inputTimeFormatter = DateFormatter()
        inputTimeFormatter.locale = Locale(identifier: "ko_KR")
        inputTimeFormatter.dateFormat = "a h:mm"
        let outputTimeFormatter = DateFormatter()
        outputTimeFormatter.dateFormat = "HH:mm"
        
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
        
        var previousUserId: Int?
        var previousDate: String?
        var showProfile: Bool = true
        
        let allMessages = messages.map {
            var index: Int
            
            if let indexOfUserId = userIdIndex[$0.userId] {
                index = indexOfUserId
            } else {
                userIdIndex[$0.userId] = currentIndex
                index = currentIndex
                currentIndex = min(currentIndex+1, 7)
            }
            
            if $0.userId == previousUserId && $0.date == previousDate {
                showProfile = false
            } else {
                showProfile = true
            }
            previousUserId = $0.userId
            previousDate = $0.date
            
            let dateString: String
            if let date = inputDateFormatter.date(from: $0.date) {
                dateString = outputDateFormatter.string(from: date)
            } else {
                dateString = $0.date
            }
            
            let time: String
            if let date = inputTimeFormatter.date(from: $0.time) {
                time = outputTimeFormatter.string(from: date)
            } else {
                time = $0.time
            }
            
            return CallVanChatMessage(
                userId: $0.userId,
                senderNickname: $0.senderNickname,
                content: $0.content,
                date: dateString,
                time: time,
                isImage: $0.isImage,
                isLeftUser: $0.isLeftUser,
                isMine: $0.isMine,
                index: index,
                showProfile: showProfile,
                profileImage: profileImages[index]
            )
        }
        let groupedMessages = Dictionary(grouping: allMessages, by: { $0.date })
        let sortedDates = groupedMessages.keys.sorted(by: { date1, date2 in
            guard let date1 = outputDateFormatter.date(from: date1),
                  let date2 = outputDateFormatter.date(from: date2) else {
                return date1 < date2
            }
            return date1 < date2
        })
        let sectionMessages = sortedDates.map { date in
            groupedMessages[date] ?? []
        }
        return CallVanChat(
            roomName: roomName,
            dates: sortedDates.reversed(),
            messages: sectionMessages.map { $0.reversed() }.reversed()
        )
    }
}

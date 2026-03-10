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
        outputTimeFormatter.dateFormat = "hh:mm"
        
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
        let sortedDates = groupedMessages.keys.sorted()
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

extension CallVanChatDto {
    
    static func dummy() -> CallVanChatDto {
        return CallVanChatDto(
            roomName: "별관동 -> 천안역 (14:00) (4명)",
            messages: CallVanChatMessageDto.dummy()
        )
    }
}

extension CallVanChatMessageDto {
    
    static func dummy() -> [CallVanChatMessageDto] {
        return [
            CallVanChatMessageDto(userId: 2, senderNickname: "익명_8821", content: "안녕하세요! 다들 어디쯤이신가요?", date: "2026. 03. 08", time: "오후 1:45", isImage: false, isLeftUser: false, isMine: false),
            
            CallVanChatMessageDto(userId: 1, senderNickname: "익명_12345", content: "저는 지금 기숙사 앞입니다!", date: "2026. 03. 08", time: "오후 1:46", isImage: false, isLeftUser: false, isMine: true),
            
            CallVanChatMessageDto(userId: 3, senderNickname: "익명_5522", content: "저도 방금 나왔습니다. 별관동 벤치에 앉아있어요.", date: "2026. 03. 08", time: "오후 1:47", isImage: false, isLeftUser: false, isMine: false),
            
            // 💡 둘째 날 (2026. 03. 09) - 아까 만드신 Dictionary(grouping:)이 빛을 발할 구간!
            CallVanChatMessageDto(userId: 1, senderNickname: "익명_12345", content: "아, 보이네요! 지금 그쪽으로 갈게요.", date: "2026. 03. 09", time: "오후 1:48", isImage: false, isLeftUser: false, isMine: true),
            
            CallVanChatMessageDto(userId: 2, senderNickname: "익명_8821", content: "https://stage-static.koreatech.in/upload/LOST_ITEMS/2026/1/18/18f40175-92c3-41ef-bb21-59b73303b333/tablet.png", date: "2026. 03. 09", time: "오후 1:50", isImage: true, isLeftUser: false, isMine: false),
            
            CallVanChatMessageDto(userId: 3, senderNickname: "익명_5522", content: "익명_5522님이 채팅방을 나갔습니다.", date: "2026. 03. 09", time: "오후 1:55", isImage: false, isLeftUser: true, isMine: false)
        ]
    }
}

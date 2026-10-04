//
//  RecruitChatMessageDto.swift
//  koin
//
//  Created by 홍기정 on 10/4/26.
//

import Foundation

struct RecruitChatMessageDto: Decodable {
    let messageId: Int
    let userId: Int
    let userNickname: String
    let content: String
    let timestamp: String
    let isImage: Bool
    let unreadCount: Int

    enum CodingKeys: String, CodingKey {
        case messageId = "message_id"
        case userId = "user_id"
        case userNickname = "user_nickname"
        case content, timestamp
        case isImage = "is_image"
        case unreadCount = "unread_count"
    }
}

extension Array where Element == RecruitChatMessageDto {
    func toDomain(myUserId: Int) -> RecruitChatMessageList {
        let profileImages: [ImageAsset] = [
            .callVanProfile0, .callVanProfile1, .callVanProfile2, .callVanProfile3,
            .callVanProfile4, .callVanProfile5, .callVanProfile6, .callVanProfile7
        ]
        let timestampFormatter = DateFormatter().then {
            $0.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            $0.locale = Locale(identifier: "en_US_POSIX")
            $0.timeZone = TimeZone(identifier: "Asia/Seoul")
            $0.calendar = Calendar(identifier: .gregorian)
        }

        var profileIndexByUserId: [Int: Int] = [:]
        var previousUserId: Int?
        var previousDate: String?

        let messages: [RecruitChatMessage] = sorted { $0.messageId < $1.messageId }.compactMap { dto in
            guard let timestamp = timestampFormatter.date(from: dto.timestamp) else {
                return nil
            }
            let date = timestamp.formatDateToYYYY년M월D일()

            let profileIndex = profileIndexByUserId[dto.userId] ?? Swift.min(profileIndexByUserId.count, profileImages.count - 1)
            profileIndexByUserId[dto.userId] = profileIndex

            let showProfile = !(dto.userId == previousUserId && date == previousDate)
            previousUserId = dto.userId
            previousDate = date

            return RecruitChatMessage(
                messageId: dto.messageId,
                userId: dto.userId,
                userNickname: dto.userNickname,
                content: dto.content,
                timestamp: timestamp,
                isImage: dto.isImage,
                unreadCount: dto.unreadCount,
                isMine: dto.userId == myUserId,
                showProfile: showProfile,
                profileImage: profileImages[profileIndex]
            )
        }

        var dates: [String] = []
        var sections: [[RecruitChatMessage]] = []
        for message in messages {
            let date = message.timestamp.formatDateToYYYY년M월D일()
            if dates.last == date {
                sections[sections.count - 1].append(message)
            } else {
                dates.append(date)
                sections.append([message])
            }
        }

        return RecruitChatMessageList(
            dates: dates.reversed(),
            messages: sections.map { $0.reversed() }.reversed()
        )
    }
}

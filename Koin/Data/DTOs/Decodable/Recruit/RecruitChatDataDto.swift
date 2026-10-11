//
//  RecruitChatDataDto.swift
//  koin
//
//  Created by 홍기정 on 10/4/26.
//

import Foundation

struct RecruitChatDataDto: Decodable {
    let chatRoomId: Int
    let roomName: String
    let roomType: RecruitChatRoomTypeDto
    let memberCount: Int?
    let maxMemberCount: Int?

    enum CodingKeys: String, CodingKey {
        case chatRoomId = "chat_room_id"
        case roomName = "room_name"
        case roomType = "room_type"
        case memberCount = "member_count"
        case maxMemberCount = "max_member_count"
    }
}

enum RecruitChatRoomTypeDto: String, Decodable {
    case team = "TEAM"
    case direct = "DIRECT"
}

extension RecruitChatDataDto {
    func toDomain() -> RecruitChatData {
        return RecruitChatData(
            chatRoomId: chatRoomId,
            chatRoomName: roomName,
            chatRoomType: roomType.toDomain(),
            currentMemberCount: memberCount,
            maximumMemberCount: maxMemberCount
        )
    }
}

extension RecruitChatRoomTypeDto {
    func toDomain() -> RecruitChatRoomType {
        switch self {
        case .team:
            return .team
        case .direct:
            return .direct
        }
    }
}

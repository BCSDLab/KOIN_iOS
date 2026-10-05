//
//  RecruitMyPostListDto.swift
//  koin
//
//  Created by 홍기정 on 10/4/26.
//

import Foundation

struct RecruitMyPostListDto: Decodable {
    let recruitments: [RecruitMyPostRowDto]
    let totalCount: Int
    let currentCount: Int
    let totalPage: Int
    let currentPage: Int

    enum CodingKeys: String, CodingKey {
        case recruitments
        case totalCount = "total_count"
        case currentCount = "current_count"
        case totalPage = "total_page"
        case currentPage = "current_page"
    }
}

struct RecruitMyPostRowDto: Decodable {
    let recruitment: RecruitListSummaryDto
    let canClose: Bool
    let teamChatRoomId: Int?

    enum CodingKeys: String, CodingKey {
        case canClose = "can_close"
        case teamChatRoomId = "team_chat_room_id"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.recruitment = try RecruitListSummaryDto(from: decoder)
        self.canClose = try container.decode(Bool.self, forKey: .canClose)
        self.teamChatRoomId = try container.decodeIfPresent(Int.self, forKey: .teamChatRoomId)
    }
}

extension RecruitMyPostListDto {
    func toDomain() -> RecruitMyPostList {
        return RecruitMyPostList(
            recruits: recruitments.compactMap { $0.toDomain() },
            totalCount: totalCount,
            totalPage: totalPage,
            currentPage: currentPage
        )
    }
}

extension RecruitMyPostRowDto {
    func toDomain() -> RecruitMyPostRow? {
        guard let recruit = recruitment.toDomain() else {
            return nil
        }
        return RecruitMyPostRow(
            id: recruit.id,
            category: recruit.category,
            title: recruit.title,
            meetingType: recruit.meetingType,
            startDate: recruit.startDate,
            endDate: recruit.endDate,
            deadline: recruit.deadline,
            dDay: recruit.dDay,
            currentParticipants: recruit.currentParticipants,
            maximumParticipants: recruit.maximumParticipants,
            type: recruit.type,
            roles: recruit.roles,
            state: recruit.state,
            canClose: canClose,
            chatRoomId: teamChatRoomId
        )
    }
}

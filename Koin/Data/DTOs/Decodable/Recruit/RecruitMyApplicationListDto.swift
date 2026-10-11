//
//  RecruitMyApplicationListDto.swift
//  koin
//
//  Created by 홍기정 on 10/4/26.
//

import Foundation

struct RecruitMyApplicationListDto: Decodable {
    let applications: [RecruitMyApplicationRowDto]
    let totalCount: Int
    let currentCount: Int
    let totalPage: Int
    let currentPage: Int

    enum CodingKeys: String, CodingKey {
        case applications
        case totalCount = "total_count"
        case currentCount = "current_count"
        case totalPage = "total_page"
        case currentPage = "current_page"
    }
}

struct RecruitMyApplicationRowDto: Decodable {
    let applicationId: Int
    let status: RecruitApplicationStatusDto
    let teamChatRoomId: Int?
    let recruitment: RecruitListSummaryDto

    enum CodingKeys: String, CodingKey {
        case applicationId = "application_id"
        case status
        case teamChatRoomId = "team_chat_room_id"
        case recruitment
    }
}

extension RecruitMyApplicationListDto {
    func toDomain() -> RecruitMyApplicationList {
        return RecruitMyApplicationList(
            recruits: applications.compactMap { $0.toDomain() },
            totalCount: totalCount,
            totalPage: totalPage,
            currentPage: currentPage
        )
    }
}

extension RecruitMyApplicationRowDto {
    func toDomain() -> RecruitMyApplicationRow? {
        guard let recruit = recruitment.toDomain() else {
            return nil
        }
        return RecruitMyApplicationRow(
            id: recruit.id,
            category: recruit.category,
            title: recruit.title,
            meetingType: recruit.meetingType,
            startDate: recruit.startDate,
            endDate: recruit.endDate,
            deadline: recruit.deadline,
            dDay: recruit.dDay,
            state: recruit.state,
            currentParticipants: recruit.currentParticipants,
            maximumParticipants: recruit.maximumParticipants,
            type: recruit.type,
            roles: recruit.roles,
            application: RecruitMyApplication(
                id: applicationId,
                status: status.toDomain()
            ),
            chatRoomId: teamChatRoomId
        )
    }
}

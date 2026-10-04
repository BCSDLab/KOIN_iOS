//
//  RecruitMyPostDataDto.swift
//  koin
//
//  Created by 홍기정 on 10/4/26.
//

import Foundation

struct RecruitMyPostDataDto: Decodable {
    let recruitment: RecruitApplicantRecruitmentDto
    let applications: [RecruitApplicantRowDto]
    let totalCount: Int
    let currentCount: Int
    let totalPage: Int
    let currentPage: Int

    enum CodingKeys: String, CodingKey {
        case recruitment, applications
        case totalCount = "total_count"
        case currentCount = "current_count"
        case totalPage = "total_page"
        case currentPage = "current_page"
    }
}

struct RecruitApplicantRecruitmentDto: Decodable {
    let recruitment: RecruitListSummaryDto
    let teamChatRoomId: Int?

    enum CodingKeys: String, CodingKey {
        case teamChatRoomId = "team_chat_room_id"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.recruitment = try RecruitListSummaryDto(from: decoder)
        self.teamChatRoomId = try container.decodeIfPresent(Int.self, forKey: .teamChatRoomId)
    }
}

struct RecruitApplicantRowDto: Decodable {
    let applicationId: Int
    let nickname: String
    let department: String
    let studentYear: Int
    let role: RecruitApplicationRoleDto?
    let status: RecruitApplicationStatusDto
    let canOpenDirectChat: Bool

    enum CodingKeys: String, CodingKey {
        case applicationId = "application_id"
        case nickname, department
        case studentYear = "student_year"
        case role, status
        case canOpenDirectChat = "can_open_direct_chat"
    }
}

struct RecruitApplicationRoleDto: Decodable {
    let id: Int
    let name: String
}

extension RecruitMyPostDataDto {
    func toDomain() -> RecruitMyPostData {
        let recruit = recruitment.recruitment.toDomain()
        return RecruitMyPostData(
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
            chatRoomId: recruitment.teamChatRoomId,
            applicants: applications.map { $0.toDomain() },
            totalCount: totalCount,
            totalPage: totalPage,
            currentPage: currentPage
        )
    }
}

extension RecruitApplicantRowDto {
    func toDomain() -> RecruitApplicantRow {
        return RecruitApplicantRow(
            applicationId: applicationId,
            nickname: nickname,
            department: department,
            studentYear: studentYear,
            role: role?.name ?? "",
            status: status.toDomain(),
            canChat: canOpenDirectChat
        )
    }
}

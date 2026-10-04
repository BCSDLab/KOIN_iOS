//
//  RecruitDataDto.swift
//  koin
//
//  Created by 홍기정 on 10/2/26.
//

import Foundation

struct RecruitDataDto: Decodable {
    let id: Int
    let category: RecruitCategoryDto
    let title: String
    let meetingType: RecruitMeetingTypeDto
    let activityStartDate: String
    let activityEndDate: String
    let deadlineDate: String
    let dDay: Int?
    let status: RecruitStatusDto
    let recruitmentType: RecruitRoleTypeDto
    let currentParticipants: Int
    let maxParticipants: Int
    let roles: [RecruitRoleDto]
    let authorNickname: String?
    let description: String
    let relatedUrl: String?
    let qualification: String?
    let createdAt: String
    let isAuthor: Bool
    let canApply: Bool
    let applyBlockReason: RecruitApplyBlockReasonDto?
    let application: RecruitMyApplicationDto?
    let canManageApplicants: Bool
    let teamChatAvailable: Bool
    let teamChatRoomId: Int?

    enum CodingKeys: String, CodingKey {
        case id, category, title
        case meetingType = "meeting_type"
        case activityStartDate = "activity_start_date"
        case activityEndDate = "activity_end_date"
        case deadlineDate = "deadline_date"
        case dDay = "d_day"
        case status
        case recruitmentType = "recruitment_type"
        case currentParticipants = "current_participants"
        case maxParticipants = "max_participants"
        case roles
        case authorNickname = "author_nickname"
        case description
        case relatedUrl = "related_url"
        case qualification
        case createdAt = "created_at"
        case isAuthor = "is_author"
        case canApply = "can_apply"
        case applyBlockReason = "apply_block_reason"
        case application
        case canManageApplicants = "can_manage_applicants"
        case teamChatAvailable = "team_chat_available"
        case teamChatRoomId = "team_chat_room_id"
    }
}

struct RecruitMyApplicationDto: Decodable {
    let applicationId: Int
    let status: RecruitApplicationStatusDto

    enum CodingKeys: String, CodingKey {
        case applicationId = "application_id"
        case status
    }
}

extension RecruitDataDto {
    func toDomain() -> RecruitData {
        let createdAtFormatter = DateFormatter().then {
            $0.dateFormat = "yyyy-MM-dd HH:mm:ss"
            $0.locale = Locale(identifier: "ko_KR")
            $0.calendar = Calendar(identifier: .gregorian)
        }

        return RecruitData(
            id: id,
            category: category.toDomain(),
            dDay: dDay?.toDDay(),
            state: status.toDomain(),
            title: title,
            meetingType: meetingType.toDomain(),
            startDate: activityStartDate.toDateFromYYYYMMDD(),
            endDate: activityEndDate.toDateFromYYYYMMDD(),
            deadlineDate: deadlineDate.toDateFromYYYYMMDD(),
            currentParticipants: currentParticipants,
            maximumParticipants: maxParticipants,
            createdAt: createdAtFormatter.date(from: createdAt),
            author: authorNickname,
            type: recruitmentType.toDomain(),
            roles: roles.map { $0.toDomain() },
            description: description,
            relatedUrl: relatedUrl.flatMap { URL(string: $0) },
            qualification: qualification,
            application: application?.toDomain(),
            isAuthor: isAuthor,
            canApply: canApply,
            applyBlockReason: applyBlockReason?.toDomain(),
            canManageApplicants: canManageApplicants,
            teamChatAvailable: teamChatAvailable,
            teamChatRoomId: teamChatRoomId
        )
    }
}

extension RecruitMyApplicationDto {
    func toDomain() -> RecruitMyApplication {
        return RecruitMyApplication(
            id: applicationId,
            status: status.toDomain()
        )
    }
}

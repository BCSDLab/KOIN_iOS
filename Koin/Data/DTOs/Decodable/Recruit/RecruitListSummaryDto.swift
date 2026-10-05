//
//  RecruitListSummaryDto.swift
//  koin
//
//  Created by 홍기정 on 10/1/26.
//

import Foundation

struct RecruitListSummaryDto: Decodable {
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
    }
}

extension RecruitListSummaryDto {
    func toDomain() -> RecruitRow? {
        guard let state = status.toDomain() else {
            return nil
        }
        return RecruitRow(
            id: id,
            category: category.toDomain(),
            title: title,
            meetingType: meetingType.toDomain(),
            startDate: activityStartDate.toDateFromYYYYMMDD(),
            endDate: activityEndDate.toDateFromYYYYMMDD(),
            deadline: deadlineDate.toDateFromYYYYMMDD(),
            dDay: dDay?.toDDay(),
            state: state,
            currentParticipants: currentParticipants,
            maximumParticipants: maxParticipants,
            type: recruitmentType.toDomain(),
            roles: roles.map { $0.toDomain() }
        )
    }
}

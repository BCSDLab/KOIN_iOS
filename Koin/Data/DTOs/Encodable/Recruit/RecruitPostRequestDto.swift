//
//  RecruitPostRequestDto.swift
//  koin
//
//  Created by 홍기정 on 10/2/26.
//

import Foundation

struct RecruitPostRequestDto: Encodable {
    let category: RecruitCategoryDto
    let title: String
    let meetingType: RecruitMeetingTypeDto
    let activityStartDate: String
    let activityEndDate: String
    let deadlineDate: String
    let recruitmentType: RecruitRoleTypeDto
    let maxParticipants: Int?
    let roles: [RecruitRoleRequestDto]
    let description: String
    let relatedUrl: String?
    let qualification: String?

    enum CodingKeys: String, CodingKey {
        case category, title
        case meetingType = "meeting_type"
        case activityStartDate = "activity_start_date"
        case activityEndDate = "activity_end_date"
        case deadlineDate = "deadline_date"
        case recruitmentType = "recruitment_type"
        case maxParticipants = "max_participants"
        case roles, description
        case relatedUrl = "related_url"
        case qualification
    }
}

struct RecruitRoleRequestDto: Encodable {
    let id: Int?
    let name: String
    let maxParticipants: Int

    enum CodingKeys: String, CodingKey {
        case id, name
        case maxParticipants = "max_participants"
    }
}

extension RecruitPostRequestDto {
    init?(from request: RecruitPostRequest) {
        guard let category = request.category,
              let title = request.title,
              let meetingType = request.meetingType,
              let startDate = request.startDate,
              let endDate = request.endDate,
              let deadline = request.deadline,
              let description = request.description else {
            return nil
        }

        self.category = RecruitCategoryDto(from: category)
        self.title = title
        self.meetingType = RecruitMeetingTypeDto(from: meetingType)
        self.activityStartDate = startDate.formatDateToYYYYMMDD(separator: "-")
        self.activityEndDate = endDate.formatDateToYYYYMMDD(separator: "-")
        self.deadlineDate = deadline.formatDateToYYYYMMDD(separator: "-")
        self.recruitmentType = RecruitRoleTypeDto(from: request.type)
        switch request.type {
        case .roleBased:
            self.maxParticipants = nil
            self.roles = request.roles.map { RecruitRoleRequestDto(from: $0) }
        case .general:
            self.maxParticipants = request.numberOfGeneralMembers
            self.roles = []
        }
        self.description = description
        self.relatedUrl = request.relatedUrl
        
        let qualification = request.qualification?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.qualification = (qualification?.isEmpty ?? true) ? nil : qualification
    }
}

extension RecruitRoleRequestDto {
    init(from request: RecruitRoleRequest) {
        self.id = request.id
        self.name = request.name
        self.maxParticipants = request.maximumParticipants
    }
}

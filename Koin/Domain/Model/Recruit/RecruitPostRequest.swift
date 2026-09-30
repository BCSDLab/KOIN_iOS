//
//  RecruitPostRequest.swift
//  koin
//
//  Created by 홍기정 on 8/29/26.
//

import Foundation
import Then

struct RecruitPostRequest {
    var category: RecruitCategory?
    var title: String?
    var meetingType: RecruitMeetingType?
    var startDate: Date?
    var endDate: Date?
    var deadline: Date?
    var type: RecruitRoleType = .roleBased
    var numberOfGeneralMembers: Int?
    var roles: [RecruitRoleRequest] = [.init()]
    var description: String?
    var relatedUrl: String?
    var qualification: String?
    
    var isValid: Bool {
        guard let category,
              let title,
              !title.isEmpty,
              let meetingType,
              let startDate,
              let endDate,
              let deadline,
              let description,
              !description.isEmpty,
              !(startDate < endDate),
              !(endDate < deadline) else {
            return false
        }
              
        switch type {
        case .roleBased:
            guard !roles.isEmpty else {
                return false
            }
            for role in roles {
                guard role.isValid else {
                    return false
                }
            }
            return true
        case .general:
            return roles.isEmpty
        }
    }
}

struct RecruitRoleRequest {
    var name: String = ""
    var maximumParticipants: Int = 1
    
    var isValid: Bool {
        !name.isEmpty && 1 <= maximumParticipants && maximumParticipants <= 10
    }
}

extension RecruitPostRequest {
    init(from data: RecruitData) {
        self.category = data.category
        self.title = data.title
        self.meetingType = data.meetingType
        self.startDate = data.startDate
        self.endDate = data.endDate
        self.deadline = data.deadlineDate
        self.type = data.type
        self.numberOfGeneralMembers = data.maximumParticipants
        self.roles = data.roles.map { .init(from: $0) }
        self.description = data.description
        self.relatedUrl = data.relatedUrl?.absoluteString
        self.qualification = data.qualification
    }
}

extension RecruitRoleRequest {
    init(from form: RecruitRole) {
        self.name = form.name
        self.maximumParticipants = form.maximumParticipants
    }
}

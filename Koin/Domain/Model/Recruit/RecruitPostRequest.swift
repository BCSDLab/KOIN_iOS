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
        case .general:
            guard roles.isEmpty, numberOfGeneralMembers != nil else {
                return false
            }
        }
        return category != nil
        && !(title?.isEmpty ?? true)
        && meetingType != nil
        && startDate != nil
        && endDate != nil
        && deadline != nil
        && description != nil
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
    init(from form: RecruitDetail) {
        let dateFormatter = DateFormatter().then {
            $0.dateFormat = "yyyy-MM-dd"
        }
        
        self.category = form.category
        self.title = form.title
        self.meetingType = form.meetingType
        self.startDate = dateFormatter.date(from: form.startDate)
        self.endDate = dateFormatter.date(from: form.endDate)
        self.deadline = dateFormatter.date(from: form.deadline)
        self.type = form.type
        self.numberOfGeneralMembers = form.maximumParticipants
        self.roles = form.roles.map { .init(from: $0) }
        self.description = form.description
        self.relatedUrl = form.relatedUrl
        self.qualification = form.qualification
    }
}

extension RecruitRoleRequest {
    init(from form: RecruitRole) {
        self.name = form.name
        self.maximumParticipants = form.maximumParticipants
    }
}

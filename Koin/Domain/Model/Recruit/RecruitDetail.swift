//
//  RecruitDetail.swift
//  koin
//
//  Created by 홍기정 on 8/29/26.
//

import Foundation

struct RecruitDetail: Identifiable, Equatable {
    let id: Int
    let category: RecruitCategory
    let title: String
    let meetingType: RecruitMeetingType
    
    let startDate: String
    let endDate: String
    let deadline: String
    let dDay: Int
    
    let state: RecruitState

    let currentParticipants: Int
    let maximumParticipants: Int
    
    let type: RecruitRoleType
    let roles: [RecruitRole]
    
    let description: String
    let relatedUrl: String?
    let qualification: String?
}

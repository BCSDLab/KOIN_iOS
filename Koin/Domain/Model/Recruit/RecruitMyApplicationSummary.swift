//
//  RecruitMyApplicationSummary.swift
//  koin
//
//  Created by 홍기정 on 9/24/26.
//

import Foundation

struct RecruitMyApplicationSummary: Identifiable, Equatable {
    let id: Int
    let category: RecruitCategory
    let title: String
    let meetingType: RecruitMeetingType

    let startDate: Date
    let endDate: Date
    let deadline: Date
    let dDay: String

    let currentParticipants: Int
    let maximumParticipants: Int

    let type: RecruitRoleType
    let roles: [RecruitRole]

    let status: RecruitMyApplicationStatus
    let chatRoomId: Int?
}

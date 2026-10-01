//
//  RecruitMyApplicationRow.swift
//  koin
//
//  Created by 홍기정 on 9/24/26.
//

import Foundation

struct RecruitMyApplicationRow: Identifiable, Equatable {
    let id: Int
    let category: RecruitCategory
    let title: String
    let meetingType: RecruitMeetingType

    let startDate: Date
    let endDate: Date
    let deadline: Date
    let dDay: String
    let state: RecruitState

    let currentParticipants: Int
    let maximumParticipants: Int

    let type: RecruitRoleType
    let roles: [RecruitRole]

    let application: RecruitMyApplication
    let chatRoomId: Int?
}

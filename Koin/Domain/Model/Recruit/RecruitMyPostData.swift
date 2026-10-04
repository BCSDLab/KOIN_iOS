//
//  RecruitMyPostData.swift
//  koin
//
//  Created by 홍기정 on 10/1/26.
//

import Foundation

struct RecruitMyPostData: Identifiable, Equatable {
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

    let state: RecruitState
    let chatRoomId: Int?

    var applicants: [RecruitApplicantRow]
    let totalCount: Int
    let totalPage: Int
    let currentPage: Int
}

extension RecruitMyPostData {
    var hasNextPage: Bool {
        currentPage < totalPage
    }
}

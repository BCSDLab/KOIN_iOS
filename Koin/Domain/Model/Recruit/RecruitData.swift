//
//  RecruitData.swift
//  koin
//
//  Created by 홍기정 on 8/29/26.
//

import Foundation

struct RecruitData: Identifiable, Equatable {
    let id: Int
    
    let category: RecruitCategory
    let dDay: String?
    let state: RecruitState
    let title: String
    
    let meetingType: RecruitMeetingType
    let startDate: Date?
    let endDate: Date?
    let deadlineDate: Date?
    let currentParticipants: Int
    let maximumParticipants: Int
    let createdAt: Date?
    let author: String?
    
    let type: RecruitRoleType
    let roles: [RecruitRole]
    
    let description: String
    let relatedUrl: URL?
    let qualification: String?
    
    let application: RecruitMyApplication?
    
    let isAuthor: Bool
    private(set) var canApply: Bool
    private(set) var applyBlockReason: RecruitApplyBlockReason?
    let canManageApplicants: Bool
    let teamChatAvailable: Bool
    let teamChatRoomId: Int?
}

extension RecruitData {
    mutating func markAsAlreadyApplied() {
        canApply = false
        applyBlockReason = .alreadyApplied
    }
}

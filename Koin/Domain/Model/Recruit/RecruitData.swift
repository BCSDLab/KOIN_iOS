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
    let dDay: String
    let title: String
    
    let meetingType: RecruitMeetingType
    let startDate: Date
    let endDate: Date
    let deadlineDate: Date
    let currentParticipants: Int
    let maximumParticipants: Int
    let createdAt: Date?
    let author: String?
    
    let type: RecruitRoleType
    let roles: [RecruitRole]
    
    let description: String
    let relatedUrl: URL?
    let qualification: String?
    
    let isAuthor: Bool
    let canApply: Bool
    let applyBlockReason: String?
    let canManageApplicants: Bool
    let teamChatAvailable: Bool
    let teamChatRoomId: Int?
}

extension RecruitData {
    func disablingApplication() -> RecruitData {
        RecruitData(
            id: id,
            category: category,
            dDay: dDay,
            title: title,
            meetingType: meetingType,
            startDate: startDate,
            endDate: endDate,
            deadlineDate: deadlineDate,
            currentParticipants: currentParticipants,
            maximumParticipants: maximumParticipants,
            createdAt: createdAt,
            author: author,
            type: type,
            roles: roles,
            description: description,
            relatedUrl: relatedUrl,
            qualification: qualification,
            isAuthor: isAuthor,
            canApply: false,
            applyBlockReason: "이미 지원한 모집글입니다.",
            canManageApplicants: canManageApplicants,
            teamChatAvailable: teamChatAvailable,
            teamChatRoomId: teamChatRoomId
        )
    }
}

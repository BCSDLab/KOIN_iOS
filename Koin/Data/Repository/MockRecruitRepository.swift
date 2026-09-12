//
//  MockRecruitRepository.swift
//  koin
//
//  Created by 홍기정 on 8/29/26.
//

import Foundation

final class MockRecruitRepository: RecruitRepository {
    func fetchList(_ filter: RecruitListFilter) async throws -> RecruitList {
        let contest = RecruitDetail(
            id: 1,
            category: .contest,
            title: "AI 아이디어 공모전 팀원 모집",
            meetingType: .online,
            startDate: "2026.07.26",
            endDate: "2026.08.07",
            deadline: "2026.08.07",
            dDay: 5,
            state: .recruiting,
            currentParticipants: 0,
            maximumParticipants: 3,
            type: .roleBased,
            roles: [
                RecruitRole(id: 1, name: "프론트엔드", currentParticipants: 0, maximumParticipants: 1, isClosed: false),
                RecruitRole(id: 2, name: "백엔드", currentParticipants: 0, maximumParticipants: 1, isClosed: false),
                RecruitRole(id: 3, name: "디자인", currentParticipants: 0, maximumParticipants: 1, isClosed: false)
            ],
            description: "",
            relatedUrl: nil,
            qualification: nil
        )
        
        let externalActivity = RecruitDetail(
            id: 2,
            category: .externalActivity,
            title: "2026 대외활동 팀원 모집",
            meetingType: .mixed,
            startDate: "2026.07.26",
            endDate: "2026.08.07",
            deadline: "2026.08.07",
            dDay: 13,
            state: .recruiting,
            currentParticipants: 2,
            maximumParticipants: 3,
            type: .general,
            roles: [],
            description: "",
            relatedUrl: nil,
            qualification: nil
        )
        
        let closedExternalActivity = RecruitDetail(
            id: 3,
            category: .externalActivity,
            title: "2026 대외활동 팀원 모집",
            meetingType: .mixed,
            startDate: "2026.07.26",
            endDate: "2026.08.07",
            deadline: "2026.08.07",
            dDay: 0,
            state: .closed,
            currentParticipants: 5,
            maximumParticipants: 5,
            type: .general,
            roles: [],
            description: "",
            relatedUrl: nil,
            qualification: nil
        )
        
        let studies = (4...7).map { id in
            RecruitDetail(
                id: id,
                category: .study,
                title: "2026 스터디 팀원 모집",
                meetingType: .mixed,
                startDate: "2026.07.26",
                endDate: "2026.08.07",
                deadline: "2026.08.07",
                dDay: 13,
                state: .recruiting,
                currentParticipants: 2,
                maximumParticipants: 3,
                type: .general,
                roles: [],
                description: "",
                relatedUrl: nil,
                qualification: nil
            )
        }
        
        return RecruitList(
            recruits: [contest, externalActivity, closedExternalActivity] + studies,
            totalCount: 7,
            totalPage: 1,
            currentPage: 1
        )
    }
    
    func fetchDetail(_ id: Int) async throws -> RecruitDetail {
        try await Task.sleep(nanoseconds: 300_000_000)
        return RecruitDetail(
            id: id,
            category: .contest,
            title: "AI 아이디어 공모전 팀원 모집",
            meetingType: .online,
            startDate: "2026.07.26",
            endDate: "2026.08.07",
            deadline: "2026.08.07",
            dDay: 5,
            state: .recruiting,
            currentParticipants: 0,
            maximumParticipants: 3,
            type: .roleBased,
            roles: [
                RecruitRole(id: 1, name: "프론트엔드", currentParticipants: 0, maximumParticipants: 1, isClosed: false),
                RecruitRole(id: 2, name: "백엔드", currentParticipants: 0, maximumParticipants: 1, isClosed: false),
                RecruitRole(id: 3, name: "디자인", currentParticipants: 0, maximumParticipants: 1, isClosed: false)
            ],
            description: "소개소개소개소개소개소개소개소개소개소개",
            relatedUrl: nil,
            qualification: "2학년이상\n참여율 높은 사람\n@@@"
        )
    }
    
    func post(_ request: RecruitPostRequest) async throws -> Int {
        return 1
    }
    
    func modify(_ id: Int, _ request: RecruitPostRequest) async throws -> Void {
        return
    }
    
    func fetchNotificationList() async throws -> RecruitNotificationList {
        return RecruitNotificationList(notifications: [
            RecruitNotification(
                id: 1,
                chatRoomId: 1,
                type: .chat,
                title: "팀원모집 @@님의 메시지",
                content: "메세지메세지",
                dateText: "2시간 전",
                isRead: false
            ),
            RecruitNotification(
                id: 2,
                chatRoomId: 0,
                type: .default,
                title: "팀원 모집 지원 승인",
                content: "지원했던 AI 공모전 팀원 모집에 승인되었어요.",
                dateText: "2시간 전",
                isRead: false
            ),
            RecruitNotification(
                id: 3,
                chatRoomId: 0,
                type: .default,
                title: "팀원 모집 지원 거절",
                content: "지원했던 AI 공모전 팀원 모집에 승인 거절되었어요.\n다른 모집글에 지원해보세요.",
                dateText: "2시간 전",
                isRead: false
            ),
            RecruitNotification(
                id: 4,
                chatRoomId: 0,
                type: .default,
                title: "팀원 모집글 삭제",
                content: "지원했던 AI 공모전 팀원 모집글이 삭제되었어요.\n다른 모집글에 지원해보세요.",
                dateText: "2시간 전",
                isRead: false
            ),
            RecruitNotification(
                id: 5,
                chatRoomId: 0,
                type: .default,
                title: "팀원 모집기간 종료",
                content: "작성했던 AI 공모전 팀원 모집 기간이 종료되었어요.",
                dateText: "2시간 전",
                isRead: false
            )
        ])
    }
    
    func deleteNotification(_ id: Int) async throws -> Void {
        
    }
    
    func deleteAllNotification() async throws -> Void {
        
    }
    
    func markAsReadNotification(_ id: Int) async throws -> Void {
        
    }
    
    func markAllAsReadNotification() async throws -> Void {
        
    }
}

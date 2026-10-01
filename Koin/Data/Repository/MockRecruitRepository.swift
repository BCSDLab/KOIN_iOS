//
//  MockRecruitRepository.swift
//  koin
//
//  Created by 홍기정 on 8/29/26.
//

import Foundation

final class MockRecruitRepository: RecruitRepository {
    private var postedChatMessages: [RecruitChatMessage] = []

    func fetchTeamChatData(
        recruitmentId: Int,
        chatRoomId: Int
    ) async throws -> RecruitChatData {
        try await Task.sleep(nanoseconds: 300_000_000)

        return RecruitChatData(
            chatRoomId: chatRoomId,
            chatRoomName: "AI 아이디어 공모전 팀원 모집",
            chatRoomType: .team,
            currentMemberCount: 3,
            maximumMemberCount: 6
        )
    }

    func fetchDirectChatData(
        recruitmentId: Int,
        applicationId: Int
    ) async throws -> RecruitChatData {
        try await Task.sleep(nanoseconds: 300_000_000)

        return RecruitChatData(
            chatRoomId: applicationId + 20,
            chatRoomName: "김철수",
            chatRoomType: .direct,
            currentMemberCount: nil,
            maximumMemberCount: nil
        )
    }

    func fetchChatMessages(
        recruitmentId: Int,
        chatRoomId: Int
    ) async throws -> RecruitChatMessageList {
        try await Task.sleep(nanoseconds: 300_000_000)

        let messages = [
            RecruitChatMessage(
                messageId: 901,
                userId: 22,
                userNickname: "김철수",
                content: "안녕하세요!",
                timestamp: Date().addingTimeInterval(-120),
                isImage: false,
                unreadCount: 2,
                isMine: false,
                showProfile: true,
                profileImage: .callVanProfile0
            ),
            RecruitChatMessage(
                messageId: 902,
                userId: 23,
                userNickname: "이영희",
                content: "반갑습니다.",
                timestamp: Date().addingTimeInterval(-60),
                isImage: false,
                unreadCount: 1,
                isMine: true,
                showProfile: true,
                profileImage: .callVanProfile1
            ),
            RecruitChatMessage(
                messageId: 903,
                userId: 22,
                userNickname: "김철수",
                content: "https://placehold.co/600x400/000000/FFFFFF/png",
                timestamp: Date().addingTimeInterval(-30),
                isImage: true,
                unreadCount: 0,
                isMine: false,
                showProfile: true,
                profileImage: .callVanProfile0
            )
        ] + postedChatMessages

        return RecruitChatMessageList(
            dates: [Date().formatDateToYYYY년M월D일()],
            messages: [Array(messages.reversed())]
        )
    }

    func postChatMessage(
        recruitmentId: Int,
        chatRoomId: Int,
        request: RecruitChatPostRequest
    ) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)

        postedChatMessages.append(
            RecruitChatMessage(
                messageId: 904 + postedChatMessages.count,
                userId: 1,
                userNickname: "나",
                content: request.content,
                timestamp: Date(),
                isImage: request.isImage,
                unreadCount: 0,
                isMine: true,
                showProfile: true,
                profileImage: .callVanProfile2
            )
        )
    }

    func apply(_ request: RecruitApplyRequest) async throws -> Void {
        try await Task.sleep(nanoseconds: 300_000_000)
    }

    func postBasicInfo(_ basicInfo: BasicInfo) async throws -> BasicInfo {
        try await Task.sleep(nanoseconds: 300_000_000)
        return basicInfo
    }

    func postRecruitProfile(_ request: RecruitProfileRequest) async throws -> RecruitProfile {
        try await Task.sleep(nanoseconds: 300_000_000)

        return RecruitProfile(
            nickname: "홍길동",
            department: "컴퓨터공학부",
            studentNumber: "2023100000",
            preferredRole: request.preferredRole ?? "",
            skills: request.skills,
            activities: request.activities.enumerated().map { index, activity in
                RecruitProfileActivity(
                    id: index + 1,
                    title: activity.title ?? "",
                    startedAt: activity.startedAt ?? Date(),
                    endedAt: activity.endedAt,
                    isOngoing: activity.isOngoing,
                    description: activity.description ?? ""
                )
            },
            selfIntroduction: request.introduction ?? ""
        )
    }

    func fetchMyProfile() async throws -> RecruitProfile {
        guard UserDataManager.shared.isLoggedIn else {
            throw ErrorResponse(
                statusCode: 401,
                code: "UNAUTHORIZED",
                message: "로그인이 필요한 기능입니다."
            )
        }

        try await Task.sleep(nanoseconds: 300_000_000)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"

        guard let startedAt = dateFormatter.date(from: "2025.03.03"),
              let endedAt = dateFormatter.date(from: "2025.05.05") else {
            throw ErrorResponse.dateFormatterFailedConvert
        }

        return RecruitProfile(
            nickname: "홍길동",
            department: "컴퓨터공학부",
            studentNumber: "2023100000",
            preferredRole: "기획",
            skills: ["정보처리기사"],
            activities: [
                RecruitProfileActivity(
                    id: 1,
                    title: "AI 공모전",
                    startedAt: startedAt,
                    endedAt: endedAt,
                    isOngoing: false,
                    description: "기획 담당"
                )
            ],
            selfIntroduction: "안녕하세요."
        )
    }

    func fetchList(_ filter: RecruitListFilter) async throws -> RecruitList {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        
        let contest = RecruitRow(
            id: 1,
            category: .contest,
            title: "AI 아이디어 공모전 팀원 모집",
            meetingType: .online,
            startDate: dateFormatter.date(from: "2026.07.26") ?? Date(),
            endDate: dateFormatter.date(from: "2026.08.26") ?? Date(),
            deadline: dateFormatter.date(from: "2026.08.26") ?? Date(),
            dDay: "D-5",
            state: .recruiting,
            currentParticipants: 0,
            maximumParticipants: 3,
            type: .roleBased,
            roles: [
                RecruitRole(id: 1, name: "프론트엔드", currentParticipants: 0, maximumParticipants: 1, isClosed: true),
                RecruitRole(id: 2, name: "백엔드", currentParticipants: 0, maximumParticipants: 1, isClosed: false),
                RecruitRole(id: 3, name: "디자인", currentParticipants: 0, maximumParticipants: 1, isClosed: false)
            ]
        )
        
        let externalActivity = RecruitRow(
            id: 2,
            category: .externalActivity,
            title: "2026 대외활동 팀원 모집",
            meetingType: .mixed,
            startDate: dateFormatter.date(from: "2026.07.26") ?? Date(),
            endDate: dateFormatter.date(from: "2026.08.26") ?? Date(),
            deadline: dateFormatter.date(from: "2026.08.26") ?? Date(),
            dDay: "D-1",
            state: .recruiting,
            currentParticipants: 2,
            maximumParticipants: 3,
            type: .general,
            roles: []
        )
        
        let closedExternalActivity = RecruitRow(
            id: 3,
            category: .externalActivity,
            title: "2026 대외활동 팀원 모집",
            meetingType: .mixed,
            startDate: dateFormatter.date(from: "2026.07.26") ?? Date(),
            endDate: dateFormatter.date(from: "2026.08.26") ?? Date(),
            deadline: dateFormatter.date(from: "2026.08.26") ?? Date(),
            dDay: "D-day",
            state: .closed,
            currentParticipants: 5,
            maximumParticipants: 5,
            type: .general,
            roles: []
        )
        
        let studies = (4...7).map { id in
            RecruitRow(
                id: id,
                category: .study,
                title: "2026 스터디 팀원 모집",
                meetingType: .mixed,
                startDate: dateFormatter.date(from: "2026.07.26") ?? Date(),
                endDate: dateFormatter.date(from: "2026.08.26") ?? Date(),
                deadline: dateFormatter.date(from: "2026.08.26") ?? Date(),
                dDay: "D-1",
                state: .recruiting,
                currentParticipants: 2,
                maximumParticipants: 3,
                type: .general,
                roles: []
            )
        }
        
        return RecruitList(
            recruits: [contest, externalActivity, closedExternalActivity] + studies,
            totalCount: 7,
            totalPage: 1,
            currentPage: 1
        )
    }

    func fetchMyPostList(_ filter: RecruitMyPostFilter) async throws -> RecruitMyPostList {
        let list = try await fetchList(RecruitListFilter())
        var recruits = list.recruits.map { summary in
            RecruitMyPostRow(
                id: summary.id,
                category: summary.category,
                title: summary.title,
                meetingType: summary.meetingType,
                startDate: summary.startDate,
                endDate: summary.endDate,
                deadline: summary.deadline,
                dDay: summary.dDay,
                currentParticipants: summary.currentParticipants,
                maximumParticipants: summary.maximumParticipants,
                type: summary.type,
                roles: summary.roles,
                state: summary.state,
                canClose: summary.id != 3,
                chatRoomId: summary.id.isMultiple(of: 2) ? summary.id : nil,
                applications: mockApplications(
                    recruitId: summary.id,
                    includesRole: summary.type == .roleBased
                )
            )
        }

        if filter.state != .all {
            recruits = recruits.filter { $0.state == filter.state }
        }
        if filter.sort == .deadlineAscending {
            recruits.sort { $0.deadline < $1.deadline }
        }

        let totalCount = recruits.count
        let limit = max(filter.limit ?? totalCount, 1)
        let totalPage = max(Int(ceil(Double(totalCount) / Double(limit))), 1)
        let currentPage = min(max(filter.page, 1), totalPage)
        let startIndex = min((currentPage - 1) * limit, totalCount)
        let endIndex = min(startIndex + limit, totalCount)

        return RecruitMyPostList(
            recruits: Array(recruits[startIndex..<endIndex]),
            totalCount: totalCount,
            totalPage: totalPage,
            currentPage: currentPage
        )
    }

    func fetchMyPost(_ id: Int) async throws -> RecruitMyPostRow {
        let response = try await fetchMyPostList(RecruitMyPostFilter())
        guard let recruit = response.recruits.first(where: { $0.id == id }) else {
            throw ErrorResponse.unexpectedInternalError
        }
        return RecruitMyPostRow(
            id: recruit.id,
            category: recruit.category,
            title: recruit.title,
            meetingType: recruit.meetingType,
            startDate: recruit.startDate,
            endDate: recruit.endDate,
            deadline: recruit.deadline,
            dDay: recruit.dDay,
            currentParticipants: recruit.currentParticipants,
            maximumParticipants: recruit.maximumParticipants,
            type: recruit.type,
            roles: recruit.roles,
            state: recruit.state,
            canClose: recruit.canClose,
            chatRoomId: recruit.chatRoomId ?? recruit.id,
            applications: recruit.applications
        )
    }

    func fetchApplicant(
        recruitmentId: Int,
        applicationId: Int
    ) async throws -> RecruitApplicantData {
        try await Task.sleep(nanoseconds: 300_000_000)

        let recruitment = try await fetchMyPost(recruitmentId)
        guard let application = recruitment.applications.first(where: {
            $0.applicationId == applicationId
        }) else {
            throw ErrorResponse.unexpectedInternalError
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        guard let startedAt = dateFormatter.date(from: "2026.03.23"),
              let endedAt = dateFormatter.date(from: "2026.04.06") else {
            throw ErrorResponse.dateFormatterFailedConvert
        }

        let role = application.role.isEmpty ? nil : application.role
        return RecruitApplicantData(
            applicationId: application.applicationId,
            status: application.status,
            profile: RecruitProfile(
                nickname: application.nickname,
                department: application.department,
                studentNumber: String(format: "20%02d000000", application.studentYear),
                preferredRole: role ?? "",
                skills: ["정보처리기사"],
                activities: [
                    RecruitProfileActivity(
                        id: 1,
                        title: "AI 공모전",
                        startedAt: startedAt,
                        endedAt: endedAt,
                        isOngoing: false,
                        description: "AI 공모전에서 기획을 담당했고 @@@를 주제로 @@@를 만들었습니다"
                    )
                ],
                selfIntroduction: "안녕하세요."
            ),
            motivation: "안녕하세요.",
            availableTime: "월 수 금 20시 이후",
            role: role,
            canDecide: application.status == .pending,
            canDirectChat: application.status == .accepted && application.canChat
        )
    }

    func decideApplicant(
        recruitmentId: Int,
        applicationId: Int,
        decision: RecruitApplicantDecision
    ) async throws -> Void {
        let recruitment = try await fetchMyPost(recruitmentId)
        guard recruitment.applications.contains(where: {
            $0.applicationId == applicationId && $0.status == .pending
        }) else {
            throw ErrorResponse.unexpectedInternalError
        }
        try await Task.sleep(nanoseconds: 300_000_000)
    }

    private func mockApplications(
        recruitId: Int,
        includesRole: Bool
    ) -> [RecruitApplicantRow] {
        guard recruitId == 1 || recruitId == 2 else {
            return []
        }

        return [
            RecruitApplicantRow(
                applicationId: recruitId * 100 + 1,
                nickname: "김철수",
                department: "컴퓨터공학부",
                studentYear: 23,
                role: includesRole ? "백엔드" : "",
                status: .denied,
                canChat: false
            ),
            RecruitApplicantRow(
                applicationId: recruitId * 100 + 2,
                nickname: "김철수",
                department: "컴퓨터공학부",
                studentYear: 23,
                role: includesRole ? "디자인" : "",
                status: .accepted,
                canChat: true
            ),
            RecruitApplicantRow(
                applicationId: recruitId * 100 + 3,
                nickname: "김철수",
                department: "컴퓨터공학부",
                studentYear: 23,
                role: includesRole ? "프론트엔드" : "",
                status: .pending,
                canChat: false
            )
        ]
    }

    func closeMyPost(id: Int) async throws -> Bool {
        true
    }

    func fetchMyApplicationList(
        _ filter: RecruitMyApplicationFilter
    ) async throws -> RecruitMyApplicationList {
        let list = try await fetchList(RecruitListFilter())
        let statuses = RecruitApplicationStatus.allCases
        var recruits = list.recruits.enumerated().map { index, summary in
            RecruitMyApplicationRow(
                id: summary.id,
                category: summary.category,
                title: summary.title,
                meetingType: summary.meetingType,
                startDate: summary.startDate,
                endDate: summary.endDate,
                deadline: summary.deadline,
                dDay: summary.dDay,
                state: summary.state,
                currentParticipants: summary.currentParticipants,
                maximumParticipants: summary.maximumParticipants,
                type: summary.type,
                roles: summary.roles,
                application: RecruitMyApplication(
                    id: summary.id * 100 + index,
                    status: statuses[index % statuses.count]
                ),
                chatRoomId: summary.id.isMultiple(of: 2) ? summary.id : nil
            )
        }

        if let status = filter.status {
            recruits = recruits.filter { $0.application.status == status }
        }
        if filter.sort == .deadlineAscending {
            recruits.sort { $0.deadline < $1.deadline }
        }

        let totalCount = recruits.count
        let limit = max(filter.limit ?? totalCount, 1)
        let totalPage = max(Int(ceil(Double(totalCount) / Double(limit))), 1)
        let currentPage = min(max(filter.page, 1), totalPage)
        let startIndex = min((currentPage - 1) * limit, totalCount)
        let endIndex = min(startIndex + limit, totalCount)

        return RecruitMyApplicationList(
            recruits: Array(recruits[startIndex..<endIndex]),
            totalCount: totalCount,
            totalPage: totalPage,
            currentPage: currentPage
        )
    }
    
    func fetchData(_ id: Int) async throws -> RecruitData {
        try await Task.sleep(nanoseconds: 300_000_000)
        let list = try await fetchList(RecruitListFilter())
        guard let item = list.recruits.first(where: { $0.id == id }) else {
            throw NSError(domain: "MockRecruitRepository", code: 404)
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        return RecruitData(
            id: item.id,
            category: item.category,
            dDay: item.dDay,
            state: item.state,
            title: item.title,
            meetingType: item.meetingType,
            startDate: item.startDate,
            endDate: item.endDate,
            deadlineDate: item.deadline,
            currentParticipants: item.currentParticipants,
            maximumParticipants: item.maximumParticipants,
            createdAt: dateFormatter.date(from: "2026.07.26") ?? Date(),
            author: "@@@",
            type: item.type,
            roles: item.roles,
            description: "소개소개소개소개소개소개소개소개소개소개소개소개소개소개",
            relatedUrl: URL(string: "https://bcsdlab.com"),
            qualification: "2학년이상\n참여율 높은 사람\n@@@",
            application: nil,
            isAuthor: UserDataManager.shared.isLoggedIn && item.id % 2 == 0,
            canApply: true,
            applyBlockReason: nil,
            canManageApplicants: false,
            teamChatAvailable: false,
            teamChatRoomId: nil
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
            RecruitNotificationRow(
                id: 1,
                recruitmentId: 101,
                chatRoomId: 1,
                roomType: .team,
                applicationId: nil,
                type: .chat,
                title: "팀원모집 @@님의 메시지",
                content: "메세지메세지",
                dateText: "2시간 전",
                isRead: false
            ),
            RecruitNotificationRow(
                id: 2,
                recruitmentId: 0,
                chatRoomId: 0,
                roomType: .team,
                applicationId: nil,
                type: .default,
                title: "팀원 모집 지원 승인",
                content: "지원했던 AI 공모전 팀원 모집에 승인되었어요.",
                dateText: "2시간 전",
                isRead: false
            ),
            RecruitNotificationRow(
                id: 3,
                recruitmentId: 0,
                chatRoomId: 0,
                roomType: .team,
                applicationId: nil,
                type: .default,
                title: "팀원 모집 지원 거절",
                content: "지원했던 AI 공모전 팀원 모집에 승인 거절되었어요.\n다른 모집글에 지원해보세요.",
                dateText: "2시간 전",
                isRead: false
            ),
            RecruitNotificationRow(
                id: 4,
                recruitmentId: 0,
                chatRoomId: 0,
                roomType: .team,
                applicationId: nil,
                type: .default,
                title: "팀원 모집글 삭제",
                content: "지원했던 AI 공모전 팀원 모집글이 삭제되었어요.\n다른 모집글에 지원해보세요.",
                dateText: "2시간 전",
                isRead: false
            ),
            RecruitNotificationRow(
                id: 5,
                recruitmentId: 0,
                chatRoomId: 0,
                roomType: .team,
                applicationId: nil,
                type: .default,
                title: "팀원 모집기간 종료",
                content: "작성했던 AI 공모전 팀원 모집 기간이 종료되었어요.",
                dateText: "2시간 전",
                isRead: false
            )
        ])
    }
    
    func deleteData(id: Int) async throws -> Bool {
        true
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

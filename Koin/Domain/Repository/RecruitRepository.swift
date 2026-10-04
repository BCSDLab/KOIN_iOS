//
//  RecruitRepository.swift
//  koin
//
//  Created by 홍기정 on 8/29/26.
//

import Foundation

protocol RecruitRepository {
    func fetchTeamChatData(
        recruitmentId: Int,
        chatRoomId: Int
    ) async throws -> RecruitChatData
    func fetchDirectChatData(
        recruitmentId: Int,
        applicationId: Int
    ) async throws -> RecruitChatData
    func fetchChatMessages(
        recruitmentId: Int,
        chatRoomId: Int
    ) async throws -> RecruitChatMessageList
    func postChatMessage(
        recruitmentId: Int,
        chatRoomId: Int,
        request: RecruitChatPostRequest
    ) async throws
    func fetchList(_ filter: RecruitListFilter) async throws -> RecruitList
    func fetchMyPostList(_ filter: RecruitMyPostFilter) async throws -> RecruitMyPostList
    func fetchMyPostData(_ id: Int, page: Int) async throws -> RecruitMyPostData
    func fetchApplicant(
        recruitmentId: Int,
        applicationId: Int
    ) async throws -> RecruitApplicantData
    func decideApplicant(
        recruitmentId: Int,
        applicationId: Int,
        decision: RecruitApplicantDecision
    ) async throws -> Void
    func fetchMyApplicationList(_ filter: RecruitMyApplicationFilter) async throws -> RecruitMyApplicationList
    func closeMyPost(id: Int) async throws -> Bool
    func fetchNotificationList() async throws -> RecruitNotificationList
    func deleteNotification(_ id: Int) async throws -> Void
    func deleteAllNotification() async throws -> Void
    func markAsReadNotification(_ id: Int) async throws -> Void
    func markAllAsReadNotification() async throws -> Void
    func post(_ request: RecruitPostRequest) async throws -> Int
    func modify(_ id: Int, _ request: RecruitPostRequest) async throws -> Void
    func fetchData(_ id: Int) async throws -> RecruitData
    func deleteData(id: Int) async throws -> Bool
    func fetchMyProfile() async throws -> RecruitProfile
    func upsertMyProfile(_ request: RecruitProfileRequest) async throws -> RecruitProfile
    func apply(recruitmentId: Int, _ request: RecruitApplyRequest) async throws -> Void
}

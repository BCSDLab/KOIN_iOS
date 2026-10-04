//
//  DefaultRecruitRepository.swift
//  koin
//
//  Created by 홍기정 on 10/1/26.
//

import Foundation

final class DefaultRecruitRepository: RecruitRepository {

    private let service: RecruitService
    
    private let mockRepository = MockRecruitRepository() // TODO: API 연결 후 mock 위임 제거

    init(service: RecruitService) {
        self.service = service
    }

    func fetchList(_ filter: RecruitListFilter) async throws -> RecruitList {
        let request = RecruitListRequestDto(from: filter)
        return try await service.fetchList(request).toDomain()
    }

    func fetchData(_ id: Int) async throws -> RecruitData {
        try await service.fetchData(id).toDomain()
    }

    func deleteData(id: Int) async throws -> Bool {
        try await service.deleteData(id)
        return true
    }

    func post(_ request: RecruitPostRequest) async throws -> Int {
        guard let request = RecruitPostRequestDto(from: request) else {
            throw ErrorResponse.unexpectedInternalError
        }
        return try await service.post(request).id
    }

    func modify(_ id: Int, _ request: RecruitPostRequest) async throws -> Void {
        guard let request = RecruitPostRequestDto(from: request) else {
            throw ErrorResponse.unexpectedInternalError
        }
        try await service.modify(id, request)
    }

    func fetchMyProfile() async throws -> RecruitProfile {
        try await service.fetchMyProfile().toDomain()
    }

    func apply(recruitmentId: Int, _ request: RecruitApplyRequest) async throws -> Void {
        guard let dto = RecruitApplyRequestDto(from: request) else {
            throw ErrorResponse.unexpectedInternalError
        }
        try await service.apply(recruitmentId, dto)
    }

    func fetchMyApplicationList(_ filter: RecruitMyApplicationFilter) async throws -> RecruitMyApplicationList {
        let request = RecruitMyApplicationListRequestDto(from: filter)
        return try await service.fetchMyApplicationList(request).toDomain()
    }

    func upsertMyProfile(_ request: RecruitProfileRequest) async throws -> RecruitProfile {
        guard let request = RecruitProfileRequestDto(from: request) else {
            throw ErrorResponse.unexpectedInternalError
        }
        return try await service.upsertMyProfile(request).toDomain()
    }
}

extension DefaultRecruitRepository { // TODO: API 연결 후 mock 위임 제거

    func fetchTeamChatData(
        recruitmentId: Int,
        chatRoomId: Int
    ) async throws -> RecruitChatData {
        try await mockRepository.fetchTeamChatData(recruitmentId: recruitmentId, chatRoomId: chatRoomId)
    }

    func fetchDirectChatData(
        recruitmentId: Int,
        applicationId: Int
    ) async throws -> RecruitChatData {
        try await mockRepository.fetchDirectChatData(recruitmentId: recruitmentId, applicationId: applicationId)
    }

    func fetchChatMessages(
        recruitmentId: Int,
        chatRoomId: Int
    ) async throws -> RecruitChatMessageList {
        try await mockRepository.fetchChatMessages(recruitmentId: recruitmentId, chatRoomId: chatRoomId)
    }

    func postChatMessage(
        recruitmentId: Int,
        chatRoomId: Int,
        request: RecruitChatPostRequest
    ) async throws {
        try await mockRepository.postChatMessage(recruitmentId: recruitmentId, chatRoomId: chatRoomId, request: request)
    }

    func fetchMyPostList(_ filter: RecruitMyPostFilter) async throws -> RecruitMyPostList {
        try await mockRepository.fetchMyPostList(filter)
    }

    func fetchMyPostData(_ id: Int, page: Int) async throws -> RecruitMyPostData {
        try await mockRepository.fetchMyPostData(id, page: page)
    }

    func fetchApplicant(
        recruitmentId: Int,
        applicationId: Int
    ) async throws -> RecruitApplicantData {
        try await mockRepository.fetchApplicant(recruitmentId: recruitmentId, applicationId: applicationId)
    }

    func decideApplicant(
        recruitmentId: Int,
        applicationId: Int,
        decision: RecruitApplicantDecision
    ) async throws -> Void {
        try await mockRepository.decideApplicant(recruitmentId: recruitmentId, applicationId: applicationId, decision: decision)
    }

    func closeMyPost(id: Int) async throws -> Bool {
        try await mockRepository.closeMyPost(id: id)
    }

    func fetchNotificationList() async throws -> RecruitNotificationList {
        try await mockRepository.fetchNotificationList()
    }

    func deleteNotification(_ id: Int) async throws -> Void {
        try await mockRepository.deleteNotification(id)
    }

    func deleteAllNotification() async throws -> Void {
        try await mockRepository.deleteAllNotification()
    }

    func markAsReadNotification(_ id: Int) async throws -> Void {
        try await mockRepository.markAsReadNotification(id)
    }

    func markAllAsReadNotification() async throws -> Void {
        try await mockRepository.markAllAsReadNotification()
    }
}

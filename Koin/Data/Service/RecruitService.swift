//
//  RecruitService.swift
//  koin
//
//  Created by 홍기정 on 10/1/26.
//

import Foundation

protocol RecruitService {
    func fetchList(_ request: RecruitListRequestDto) async throws -> RecruitListDto
    func fetchData(_ id: Int) async throws -> RecruitDataDto
    func deleteData(_ id: Int) async throws
    func post(_ request: RecruitPostRequestDto) async throws -> RecruitPostResultDto
    func modify(_ id: Int, _ request: RecruitPostRequestDto) async throws
    func fetchMyProfile() async throws -> RecruitProfileDto
    func upsertMyProfile(_ request: RecruitProfileRequestDto) async throws -> RecruitProfileDto
    func apply(_ id: Int, _ request: RecruitApplyRequestDto) async throws
    func fetchMyApplicationList(_ request: RecruitMyApplicationListRequestDto) async throws -> RecruitMyApplicationListDto
    func fetchMyPostList(_ request: RecruitMyPostListRequestDto) async throws -> RecruitMyPostListDto
    func closeMyPost(_ id: Int) async throws
    func fetchMyPostData(_ id: Int, _ request: RecruitApplicantListRequestDto) async throws -> RecruitMyPostDataDto
    func fetchApplicant(recruitmentId: Int, applicationId: Int) async throws -> RecruitApplicantDataDto
    func decideApplicant(recruitmentId: Int, applicationId: Int, _ request: RecruitApplicantDecisionRequestDto) async throws
    func fetchChatData(recruitmentId: Int, chatRoomId: Int) async throws -> RecruitChatDataDto
    func fetchDirectChatData(recruitmentId: Int, applicationId: Int) async throws -> RecruitChatDataDto
    func fetchChatMessages(recruitmentId: Int, chatRoomId: Int) async throws -> [RecruitChatMessageDto]
    func postChatMessage(recruitmentId: Int, chatRoomId: Int, _ request: RecruitChatPostRequestDto) async throws
    func fetchNotificationList(_ request: RecruitNotificationListRequestDto) async throws -> RecruitNotificationListDto
    func markAsReadNotification(_ id: Int) async throws
    func markAllAsReadNotification() async throws
    func deleteNotification(_ id: Int) async throws
    func deleteAllNotification() async throws
}

final class DefaultRecruitService: RecruitService {

    private let networkService = NetworkService.shared

    func fetchList(_ request: RecruitListRequestDto) async throws -> RecruitListDto {
        try await networkService.requestWithResponse(api: RecruitAPI.fetchList(request))
    }

    func fetchData(_ id: Int) async throws -> RecruitDataDto {
        try await networkService.requestWithResponse(api: RecruitAPI.fetchData(id))
    }

    func deleteData(_ id: Int) async throws {
        try await networkService.request(api: RecruitAPI.deleteData(id))
    }

    func post(_ request: RecruitPostRequestDto) async throws -> RecruitPostResultDto {
        try await networkService.requestWithResponse(api: RecruitAPI.post(request))
    }

    func modify(_ id: Int, _ request: RecruitPostRequestDto) async throws {
        try await networkService.request(api: RecruitAPI.modify(id, request))
    }

    func fetchMyProfile() async throws -> RecruitProfileDto {
        try await networkService.requestWithResponse(api: RecruitAPI.fetchMyProfile)
    }

    func upsertMyProfile(_ request: RecruitProfileRequestDto) async throws -> RecruitProfileDto {
        try await networkService.requestWithResponse(api: RecruitAPI.upsertMyProfile(request))
    }

    func apply(_ id: Int, _ request: RecruitApplyRequestDto) async throws {
        try await networkService.request(api: RecruitAPI.apply(id, request))
    }

    func fetchMyApplicationList(_ request: RecruitMyApplicationListRequestDto) async throws -> RecruitMyApplicationListDto {
        try await networkService.requestWithResponse(api: RecruitAPI.fetchMyApplicationList(request))
    }

    func fetchMyPostList(_ request: RecruitMyPostListRequestDto) async throws -> RecruitMyPostListDto {
        try await networkService.requestWithResponse(api: RecruitAPI.fetchMyPostList(request))
    }

    func closeMyPost(_ id: Int) async throws {
        try await networkService.request(api: RecruitAPI.closeMyPost(id))
    }

    func fetchMyPostData(_ id: Int, _ request: RecruitApplicantListRequestDto) async throws -> RecruitMyPostDataDto {
        try await networkService.requestWithResponse(api: RecruitAPI.fetchMyPostData(id, request))
    }

    func fetchApplicant(recruitmentId: Int, applicationId: Int) async throws -> RecruitApplicantDataDto {
        try await networkService.requestWithResponse(api: RecruitAPI.fetchApplicant(recruitmentId: recruitmentId, applicationId: applicationId))
    }

    func decideApplicant(recruitmentId: Int, applicationId: Int, _ request: RecruitApplicantDecisionRequestDto) async throws {
        try await networkService.request(api: RecruitAPI.decideApplicant(recruitmentId: recruitmentId, applicationId: applicationId, request))
    }

    func fetchChatData(recruitmentId: Int, chatRoomId: Int) async throws -> RecruitChatDataDto {
        try await networkService.requestWithResponse(api: RecruitAPI.fetchChatData(recruitmentId: recruitmentId, chatRoomId: chatRoomId))
    }

    func fetchDirectChatData(recruitmentId: Int, applicationId: Int) async throws -> RecruitChatDataDto {
        try await networkService.requestWithResponse(api: RecruitAPI.fetchDirectChatData(recruitmentId: recruitmentId, applicationId: applicationId))
    }

    func fetchChatMessages(recruitmentId: Int, chatRoomId: Int) async throws -> [RecruitChatMessageDto] {
        try await networkService.requestWithResponse(api: RecruitAPI.fetchChatMessages(recruitmentId: recruitmentId, chatRoomId: chatRoomId))
    }

    func postChatMessage(recruitmentId: Int, chatRoomId: Int, _ request: RecruitChatPostRequestDto) async throws {
        try await networkService.request(api: RecruitAPI.postChatMessage(recruitmentId: recruitmentId, chatRoomId: chatRoomId, request))
    }

    func fetchNotificationList(_ request: RecruitNotificationListRequestDto) async throws -> RecruitNotificationListDto {
        try await networkService.requestWithResponse(api: RecruitAPI.fetchNotificationList(request))
    }

    func markAsReadNotification(_ id: Int) async throws {
        try await networkService.request(api: RecruitAPI.markAsReadNotification(id))
    }

    func markAllAsReadNotification() async throws {
        try await networkService.request(api: RecruitAPI.markAllAsReadNotification)
    }

    func deleteNotification(_ id: Int) async throws {
        try await networkService.request(api: RecruitAPI.deleteNotification(id))
    }

    func deleteAllNotification() async throws {
        try await networkService.request(api: RecruitAPI.deleteAllNotification)
    }
}

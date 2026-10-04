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
}

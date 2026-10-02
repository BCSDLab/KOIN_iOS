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
}

final class DefaultRecruitService: RecruitService {

    private let networkService = NetworkService.shared

    func fetchList(_ request: RecruitListRequestDto) async throws -> RecruitListDto {
        try await networkService.requestWithResponse(api: RecruitAPI.fetchList(request))
    }

    func fetchData(_ id: Int) async throws -> RecruitDataDto {
        try await networkService.requestWithResponse(api: RecruitAPI.fetchData(id))
    }
}

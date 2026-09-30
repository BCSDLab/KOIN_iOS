//
//  FetchRecruitMyPostApplicationUseCase.swift
//  koin
//
//  Created by 홍기정 on 9/28/26.
//

import Foundation

protocol FetchRecruitMyPostApplicationUseCase {
    func execute(
        recruitmentId: Int,
        applicationId: Int
    ) async throws -> RecruitApplication
}

final class DefaultFetchRecruitMyPostApplicationUseCase: FetchRecruitMyPostApplicationUseCase {

    private let repository: RecruitRepository

    init(repository: RecruitRepository) {
        self.repository = repository
    }

    func execute(
        recruitmentId: Int,
        applicationId: Int
    ) async throws -> RecruitApplication {
        try await repository.fetchMyPostApplication(
            recruitmentId: recruitmentId,
            applicationId: applicationId
        )
    }
}

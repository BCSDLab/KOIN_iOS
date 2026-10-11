//
//  FetchRecruitApplicantUseCase.swift
//  koin
//
//  Created by 홍기정 on 9/28/26.
//

import Foundation

protocol FetchRecruitApplicantUseCase {
    func execute(
        recruitmentId: Int,
        applicationId: Int
    ) async throws -> RecruitApplicantData
}

final class DefaultFetchRecruitApplicantUseCase: FetchRecruitApplicantUseCase {

    private let repository: RecruitRepository

    init(repository: RecruitRepository) {
        self.repository = repository
    }

    func execute(
        recruitmentId: Int,
        applicationId: Int
    ) async throws -> RecruitApplicantData {
        try await repository.fetchApplicant(
            recruitmentId: recruitmentId,
            applicationId: applicationId
        )
    }
}

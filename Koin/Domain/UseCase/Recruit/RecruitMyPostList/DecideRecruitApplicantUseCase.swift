//
//  DecideRecruitApplicantUseCase.swift
//  koin
//
//  Created by 홍기정 on 9/28/26.
//

import Foundation

protocol DecideRecruitApplicantUseCase {
    func execute(
        recruitmentId: Int,
        applicationId: Int,
        decision: RecruitApplicantDecision
    ) async throws -> Void
}

final class DefaultDecideRecruitApplicantUseCase: DecideRecruitApplicantUseCase {

    private let repository: RecruitRepository

    init(repository: RecruitRepository) {
        self.repository = repository
    }

    func execute(
        recruitmentId: Int,
        applicationId: Int,
        decision: RecruitApplicantDecision
    ) async throws -> Void {
        try await repository.decideApplicant(
            recruitmentId: recruitmentId,
            applicationId: applicationId,
            decision: decision
        )
    }
}

//
//  DecideRecruitMyPostApplicationUseCase.swift
//  koin
//
//  Created by 홍기정 on 9/28/26.
//

import Foundation

protocol DecideRecruitMyPostApplicationUseCase {
    func execute(
        recruitmentId: Int,
        applicationId: Int,
        decision: RecruitApplicationDecision
    ) async throws -> Void
}

final class DefaultDecideRecruitMyPostApplicationUseCase: DecideRecruitMyPostApplicationUseCase {

    private let repository: RecruitRepository

    init(repository: RecruitRepository) {
        self.repository = repository
    }

    func execute(
        recruitmentId: Int,
        applicationId: Int,
        decision: RecruitApplicationDecision
    ) async throws -> Void {
        try await repository.decideMyPostApplication(
            recruitmentId: recruitmentId,
            applicationId: applicationId,
            decision: decision
        )
    }
}

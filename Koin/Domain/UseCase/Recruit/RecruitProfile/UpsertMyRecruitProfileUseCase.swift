//
//  UpsertMyRecruitProfileUseCase.swift
//  koin
//
//  Created by 홍기정 on 9/21/26.
//

import Foundation

protocol UpsertMyRecruitProfileUseCase {
    func execute(request: RecruitProfileRequest) async throws -> RecruitProfile
}

final class DefaultUpsertMyRecruitProfileUseCase: UpsertMyRecruitProfileUseCase {
    private let repository: RecruitRepository

    init(repository: RecruitRepository) {
        self.repository = repository
    }

    func execute(request: RecruitProfileRequest) async throws -> RecruitProfile {
        try await repository.upsertMyProfile(request)
    }
}

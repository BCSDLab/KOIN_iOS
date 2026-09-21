//
//  PostRecruitProfileUseCase.swift
//  koin
//
//  Created by 홍기정 on 9/21/26.
//

import Foundation

protocol PostRecruitProfileUseCase {
    func execute(request: RecruitProfileRequest) async throws -> RecruitProfile
}

final class DefaultPostRecruitProfileUseCase: PostRecruitProfileUseCase {
    private let repository: RecruitRepository

    init(repository: RecruitRepository) {
        self.repository = repository
    }

    func execute(request: RecruitProfileRequest) async throws -> RecruitProfile {
        try await repository.postRecruitProfile(request)
    }
}

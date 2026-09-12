//
//  FetchMyProfileUseCase.swift
//  koin
//
//  Created by Codex on 9/13/26.
//

import Foundation

protocol FetchMyProfileUseCase {
    func execute() async throws -> RecruitProfile
}

final class DefaultFetchMyProfileUseCase: FetchMyProfileUseCase {
    private let repository: RecruitRepository

    init(repository: RecruitRepository) {
        self.repository = repository
    }

    func execute() async throws -> RecruitProfile {
        try await repository.fetchMyProfile()
    }
}

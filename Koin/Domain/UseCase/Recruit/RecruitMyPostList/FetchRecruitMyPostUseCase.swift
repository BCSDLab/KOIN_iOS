//
//  FetchRecruitMyPostUseCase.swift
//  koin
//
//  Created by 홍기정 on 9/28/26.
//

import Foundation

protocol FetchRecruitMyPostUseCase {
    func execute(id: Int) async throws -> RecruitMyPostRow
}

final class DefaultFetchRecruitMyPostUseCase: FetchRecruitMyPostUseCase {

    private let repository: RecruitRepository

    init(repository: RecruitRepository) {
        self.repository = repository
    }

    func execute(id: Int) async throws -> RecruitMyPostRow {
        try await repository.fetchMyPost(id)
    }
}

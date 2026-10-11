//
//  FetchRecruitMyApplicationListUseCase.swift
//  koin
//
//  Created by 홍기정 on 9/24/26.
//

import Foundation

protocol FetchRecruitMyApplicationListUseCase {
    func execute(filter: RecruitMyApplicationFilter) async throws -> RecruitMyApplicationList
}

final class DefaultFetchRecruitMyApplicationListUseCase: FetchRecruitMyApplicationListUseCase {

    private let repository: RecruitRepository

    init(repository: RecruitRepository) {
        self.repository = repository
    }

    func execute(filter: RecruitMyApplicationFilter) async throws -> RecruitMyApplicationList {
        try await repository.fetchMyApplicationList(filter)
    }
}

//
//  FetchRecruitMyPostListUseCase.swift
//  koin
//
//  Created by 홍기정 on 9/24/26.
//

import Foundation

protocol FetchRecruitMyPostListUseCase {
    func execute(filter: RecruitMyPostFilter) async throws -> RecruitMyPostList
}

final class DefaultFetchRecruitMyPostListUseCase: FetchRecruitMyPostListUseCase {

    private let repository: RecruitRepository

    init(repository: RecruitRepository) {
        self.repository = repository
    }

    func execute(filter: RecruitMyPostFilter) async throws -> RecruitMyPostList {
        try await repository.fetchMyPostList(filter)
    }
}

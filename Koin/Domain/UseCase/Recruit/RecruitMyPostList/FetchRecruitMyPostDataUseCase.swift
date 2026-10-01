//
//  FetchRecruitMyPostDataUseCase.swift
//  koin
//
//  Created by 홍기정 on 9/28/26.
//

import Foundation

protocol FetchRecruitMyPostDataUseCase {
    func execute(id: Int) async throws -> RecruitMyPostData
}

final class DefaultFetchRecruitMyPostDataUseCase: FetchRecruitMyPostDataUseCase {

    private let repository: RecruitRepository

    init(repository: RecruitRepository) {
        self.repository = repository
    }

    func execute(id: Int) async throws -> RecruitMyPostData {
        try await repository.fetchMyPostData(id)
    }
}

//
//  FetchRecruitListUseCase.swift
//  koin
//
//  Created by 홍기정 on 8/29/26.
//

import Foundation

protocol FetchRecruitListUseCase {
    func execute(filter: RecruitListFilter) async throws -> RecruitList
}

final class DefaultFetchRecruitListUseCase: FetchRecruitListUseCase {
    
    private let repository: RecruitRepository
    
    init(repository: RecruitRepository) {
        self.repository = repository
    }
    
    func execute(filter: RecruitListFilter) async throws -> RecruitList {
        try await repository.fetchList(filter)
    }
}

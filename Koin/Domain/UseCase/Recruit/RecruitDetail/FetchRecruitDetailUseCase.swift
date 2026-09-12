//
//  FetchRecruitDetailUseCase.swift
//  koin
//
//  Created by 홍기정 on 9/10/26.
//

import Foundation

protocol FetchRecruitDetailUseCase {
    func execute(id: Int) async throws -> RecruitDetail
}

final class DefaultFetchRecruitDetailUseCase: FetchRecruitDetailUseCase {
    
    private let repository: RecruitRepository
    
    init(repository: RecruitRepository) {
        self.repository = repository
    }
    
    func execute(id: Int) async throws -> RecruitDetail {
        try await repository.fetchDetail(id)
    }
}

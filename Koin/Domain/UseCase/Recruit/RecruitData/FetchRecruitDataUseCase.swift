//
//  FetchRecruitDataUseCase.swift
//  koin
//
//  Created by 홍기정 on 9/10/26.
//

import Foundation

protocol FetchRecruitDataUseCase {
    func execute(id: Int) async throws -> RecruitData
}

final class DefaultFetchRecruitDataUseCase: FetchRecruitDataUseCase {
    
    private let repository: RecruitRepository
    
    init(repository: RecruitRepository) {
        self.repository = repository
    }
    
    func execute(id: Int) async throws -> RecruitData {
        try await repository.fetchData(id)
    }
}

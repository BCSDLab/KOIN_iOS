//
//  PostRecruitUseCase.swift
//  koin
//
//  Created by 홍기정 on 8/30/26.
//

import Foundation

protocol PostRecruitUseCase {
    func execute(request: RecruitPostRequest) async throws -> Int
}

final class DefaultPostRecruitUseCase: PostRecruitUseCase {
    
    private let repository: RecruitRepository
    
    init(repository: RecruitRepository) {
        self.repository = repository
    }
    
    func execute(request: RecruitPostRequest) async throws -> Int {
        return try await repository.post(request)
    }
}

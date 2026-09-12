//
//  ModifyRecruitUseCase.swift
//  koin
//
//  Created by 홍기정 on 8/30/26.
//

import Foundation

protocol ModifyRecruitUseCase {
    func execute(id: Int, request: RecruitPostRequest) async throws -> Void
}

final class DefaultModifyRecruitUseCase: ModifyRecruitUseCase {
    
    private let repository: RecruitRepository
    
    init(repository: RecruitRepository) {
        self.repository = repository
    }
    
    func execute(id: Int, request: RecruitPostRequest) async throws -> Void {
        try await repository.modify(id, request)
    }
}

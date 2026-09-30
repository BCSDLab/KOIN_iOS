//
//  DeleteRecruitDataUseCase.swift
//  koin
//
//  Created by 홍기정 on 9/12/26.
//

import Foundation

protocol DeleteRecruitDataUseCase {
    func execute(id: Int) async throws -> Bool
}

final class DefaultDeleteRecruitDataUseCase: DeleteRecruitDataUseCase {
 
    private let repository: RecruitRepository
    
    init(repository: RecruitRepository) {
        self.repository = repository
    }
    
    func execute(id: Int) async throws -> Bool {
        try await repository.deleteData(id: id)
    }
}

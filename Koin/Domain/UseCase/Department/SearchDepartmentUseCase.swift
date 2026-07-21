//
//  SearchDepartmentUseCase.swift
//  koin
//
//  Created by 홍기정 on 7/19/26.
//

import Foundation

protocol SearchDepartmentUseCase {
    func execute(
        keyword: String
    ) async throws -> (
        departments: [Department],
        updatedAt: String
    )
}

final class DefaultSearchDepartmentUseCase: SearchDepartmentUseCase {
    private let repository: DepartmentRepository
    
    init(repository: DepartmentRepository) {
        self.repository = repository
    }
    
    func execute(
        keyword: String
    ) async throws -> (
        departments: [Department],
        updatedAt: String
    ) {
        try await repository.fetchDepartments(keyword: keyword)
    }
}

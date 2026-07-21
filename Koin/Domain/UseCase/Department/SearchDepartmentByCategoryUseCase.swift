//
//  SearchDepartmentByCategoryUseCase.swift
//  koin
//
//  Created by 홍기정 on 7/19/26.
//

import Foundation

protocol SearchDepartmentByCategoryUseCase {
    func execute(
        category: DepartmentCategory,
        keyword: String
    ) async throws -> (
        departments: [Department],
        updatedAt: String
    )
}

final class DefaultSearchDepartmentByCategoryUseCase: SearchDepartmentByCategoryUseCase {
    private let repository: DepartmentRepository
    
    init(repository: DepartmentRepository) {
        self.repository = repository
    }
    
    func execute(
        category: DepartmentCategory,
        keyword: String
    ) async throws -> (
        departments: [Department],
        updatedAt: String
    ) {
        return try await repository.fetchDepartmentsByCategory(
            category: category,
            keyword: keyword
        )
    }
}

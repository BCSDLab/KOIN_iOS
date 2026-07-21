//
//  FetchDepartmentUseCase.swift
//  koin
//
//  Created by 홍기정 on 7/19/26.
//

import Foundation

protocol FetchDepartmentByCategoryUseCase {
    func execute(category: DepartmentCategory) async throws -> (departments: [Department], updatedAt: String)
}

final class DefaultFetchDepartmentByCategoryUseCase: FetchDepartmentByCategoryUseCase {
    private let repository: DepartmentRepository
    
    init(repository: DepartmentRepository) {
        self.repository = repository
    }
    
    func execute(category: DepartmentCategory) async throws -> (departments: [Department], updatedAt: String) {
        try await repository.fetchDepartmentsByCategory(
            category: category,
            keyword: nil
        )
    }
}

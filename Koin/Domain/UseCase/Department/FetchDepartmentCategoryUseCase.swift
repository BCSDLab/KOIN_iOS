//
//  FetchDepartmentCategoryUseCase.swift
//  koin
//
//  Created by 홍기정 on 7/19/26.
//

import Foundation

protocol FetchDepartmentCategoryUseCase {
    func execute() async throws -> [DepartmentCategory]
}

final class DefaultFetchDepartmentCategoryUseCase: FetchDepartmentCategoryUseCase {
    private let repository: DepartmentRepository
    
    init(repository: DepartmentRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> [DepartmentCategory] {
        try await repository.fetchCategories()
    }
}

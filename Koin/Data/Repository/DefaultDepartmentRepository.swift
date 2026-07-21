//
//  DefaultDepartmentRepository.swift
//  koin
//
//  Created by 홍기정 on 7/21/26.
//

import Foundation

final class DefaultDepartmentRepository: DepartmentRepository {
    private let service: DepartmentService
    
    init(service: DepartmentService) {
        self.service = service
    }
    
    func fetchCategories() -> [DepartmentCategory] {
        return DepartmentCategory.allCases
    }
    
    func fetchDepartments(
        keyword: String
    ) async throws -> (
        departments: [Department],
        updatedAt: String
    ) {
        let request = FetchDepartmentRequestDto(keyword: keyword)
        return try await service.search(request).toDomain()
    }
}

//
//  DepartmentRepository.swift
//  koin
//
//  Created by 홍기정 on 7/21/26.
//

import Foundation

protocol DepartmentRepository {
    func fetchCategories() async throws -> [DepartmentCategory]
    
    func fetchDepartments(
        keyword: String
    ) async throws -> (
        departments: [Department],
        updatedAt: String
    )
    
    func fetchDepartmentsByCategory(
        category: DepartmentCategory,
        keyword: String?
    ) async throws -> (
        departments: [Department],
        updatedAt: String
    )
}

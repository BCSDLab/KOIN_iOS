//
//  DepartmentService.swift
//  koin
//
//  Created by 홍기정 on 6/6/26.
//

import Foundation
import Combine

protocol DepartmentService {
    func fetchDepartment(_ request: FetchDepartmentRequestDto) async throws -> DepartmentCategoriesDto
    func fetchDepartmentByCategory(_ request: FetchDepartmentByCategoryRequestDto) async throws -> DepartmentCategoryDto
}

final class DefaultDepartmentService: DepartmentService {
    
    private let networkService = NetworkService.shared
    
    func fetchDepartment(_ request: FetchDepartmentRequestDto) async throws -> DepartmentCategoriesDto {
        try await networkService.requestWithResponse(api: DepartmentAPI.fetchDepartment(request))
    }
    
    func fetchDepartmentByCategory(_ request: FetchDepartmentByCategoryRequestDto) async throws -> DepartmentCategoryDto {
        try await networkService.requestWithResponse(api: DepartmentAPI.fetchDepartmentByCategory(request))
    }
}

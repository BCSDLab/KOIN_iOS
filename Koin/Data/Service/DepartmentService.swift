//
//  DepartmentService.swift
//  koin
//
//  Created by 홍기정 on 6/6/26.
//

import Foundation
import Combine

protocol DepartmentService {
    func search(_ request: FetchDepartmentRequestDto) async throws -> DepartmentCategoriesDto
}

final class DefaultDepartmentService: DepartmentService {
    
    private let networkService = NetworkService.shared
    
    func search(_ request: FetchDepartmentRequestDto) async throws -> DepartmentCategoriesDto {
        try await networkService.requestWithResponse(api: DepartmentAPI.fetchDepartment(request))
    }
}

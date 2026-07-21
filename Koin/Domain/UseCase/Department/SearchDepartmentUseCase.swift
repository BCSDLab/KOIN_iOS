//
//  SearchDepartmentUseCase.swift
//  koin
//
//  Created by 홍기정 on 7/19/26.
//

import Foundation

protocol SearchDepartmentUseCase {
    func execute(keyword: String) async -> (departments: [Department], updatedAt: String)
}

final class MockSearchDepartmentUseCase: SearchDepartmentUseCase {
    func execute(keyword: String) async -> (departments: [Department], updatedAt: String) {
        return ([], "2022-02-22")
    }
}

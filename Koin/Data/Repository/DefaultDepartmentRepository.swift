//
//  DefaultDepartmentRepository.swift
//  koin
//
//  Created by 홍기정 on 7/21/26.
//

import Foundation

final class DefaultDepartmentRepository: DepartmentRepository {
    func fetchCategories() -> [DepartmentCategory] {
        return DepartmentCategory.allCases
    }
}

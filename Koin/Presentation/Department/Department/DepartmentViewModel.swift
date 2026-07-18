//
//  DepartmentViewModel.swift
//  koin
//
//  Created by 홍기정 on 7/18/26.
//

import Foundation
import Combine

@Observable
final class DepartmentViewModel: SwiftUIViewModelProtocol {
    
    // MARK: - Input
    enum Input {
        case viewDidAppear
    }
    
    // MARK: - Properties
    private let fetchDepartmentUseCase: FetchDepartmentUseCase
    private let category: DepartmentCategory
    private(set) var departments: [Department] = []
    private(set) var updatedAt: String = ""
    
    // MARK: - Initializer
    init(
        fetchDepartmentUseCase: FetchDepartmentUseCase,
        category: DepartmentCategory
    ) {
        self.fetchDepartmentUseCase = fetchDepartmentUseCase
        self.category = category
    }

    // MARK: - Execute
    func execute(_ input: Input) {
        switch input {
        case .viewDidAppear:
            fetchDepartment()
        }
    }
}

extension DepartmentViewModel {
    private func fetchDepartment() {
        Task {
            let (departments, updatedAt) = await fetchDepartmentUseCase.execute(category: category)
            self.departments = departments
            self.updatedAt = updatedAt
        }
    }
}

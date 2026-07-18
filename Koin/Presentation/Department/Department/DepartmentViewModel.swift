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
        case search(String)
        case endSearching
    }
    
    // MARK: - Properties
    private let fetchDepartmentUseCase: FetchDepartmentUseCase
    private let searchDepartmentUseCase: SearchDepartmentUseCase
    private let category: DepartmentCategory
    
    private(set) var departments: [Department] = []
    private(set) var updatedAt: String = ""
    
    private(set) var searchingDepartments: [Department] = []
    private(set) var searchingUpdatedAt: String = ""
    
    private(set) var isLoading: Bool = true
    
    // MARK: - Initializer
    init(
        fetchDepartmentUseCase: FetchDepartmentUseCase,
        searchDepartmentUseCase: SearchDepartmentUseCase,
        category: DepartmentCategory
    ) {
        self.fetchDepartmentUseCase = fetchDepartmentUseCase
        self.searchDepartmentUseCase = searchDepartmentUseCase
        self.category = category
    }

    // MARK: - Execute
    func execute(_ input: Input) {
        switch input {
        case .viewDidAppear:
            fetchDepartment()
        case .search(let keyword):
            search(keyword: keyword)
        case .endSearching:
            searchingDepartments.removeAll()
            searchingUpdatedAt = ""
        }
    }
}

extension DepartmentViewModel {
    private func fetchDepartment() {
        Task {
            isLoading = true
            let (departments, updatedAt) = await fetchDepartmentUseCase.execute(category: category)
            self.departments = departments
            self.updatedAt = updatedAt
            isLoading = false
        }
    }
    
    private func search(keyword: String) {
        Task {
            isLoading = true
            let (departments, updatedAt) = await searchDepartmentUseCase.execute(keyword: keyword)
            self.searchingDepartments = departments
            self.searchingUpdatedAt = updatedAt
            isLoading = false
        }
    }
}

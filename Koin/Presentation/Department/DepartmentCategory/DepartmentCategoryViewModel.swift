//
//  DepartmentCategoryViewModel.swift
//  koin
//
//  Created by 홍기정 on 7/18/26.
//

import Foundation

@Observable
final class DepartmentCategoryViewModel: SwiftUIViewModelProtocol {
    
    // MARK: - Input
    enum Input {
        case viewDidAppear
        case search(String)
        case endSearching
    }
    
    // MARK: - Properties
    private let fetchDepartmentCategoryUseCase: FetchDepartmentCategoryUseCase
    private let searchDepartmentUseCase: SearchDepartmentUseCase
    
    private(set) var categorys: [DepartmentCategory] = []
    private(set) var updatedAt: String = ""
    
    private(set) var searchingDepartments: [Department] = []
    private(set) var searchingUpdatedAt: String = ""
    
    private(set) var isLoading: Bool = true
    
    // MARK: - Initializer
    init(
        fetchDepartmentCategoryUseCase: FetchDepartmentCategoryUseCase,
        searchDepartmentUseCase: SearchDepartmentUseCase
    ) {
        self.fetchDepartmentCategoryUseCase = fetchDepartmentCategoryUseCase
        self.searchDepartmentUseCase = searchDepartmentUseCase
    }
    
    // MARK: - Execute
    func execute(_ input: Input) {
        switch input {
        case .viewDidAppear:
            fetchCategory()
        case .search(let keyword):
            search(keyword: keyword)
        case .endSearching:
            searchingDepartments.removeAll()
            searchingUpdatedAt = ""
        }
    }
}

extension DepartmentCategoryViewModel {
    private func fetchCategory() {
        Task {
            isLoading = true
            let (categories, updatedAt) = await fetchDepartmentCategoryUseCase.execute()
            self.categorys = categories
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

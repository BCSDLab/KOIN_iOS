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
        case didShowToast
    }
    
    // MARK: - Properties
    private let fetchDepartmentByCategoryUseCase: FetchDepartmentByCategoryUseCase
    private let searchDepartmentByCategoryUseCase: SearchDepartmentByCategoryUseCase
    private let category: DepartmentCategory
    
    private(set) var departments: [Department] = []
    private(set) var updatedAt: String = ""
    
    private(set) var searchingDepartments: [Department] = []
    private(set) var searchingUpdatedAt: String = ""
    
    private(set) var isLoading: Bool = true
    private var searchTask: Task<Void, Never>?
    
    private(set) var toastMessage: String?
    
    // MARK: - Initializer
    init(
        fetchDepartmentByCategoryUseCase: FetchDepartmentByCategoryUseCase,
        searchDepartmentByCategoryUseCase: SearchDepartmentByCategoryUseCase,
        category: DepartmentCategory
    ) {
        self.fetchDepartmentByCategoryUseCase = fetchDepartmentByCategoryUseCase
        self.searchDepartmentByCategoryUseCase = searchDepartmentByCategoryUseCase
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
        case .didShowToast:
            toastMessage = nil
        }
    }
}

extension DepartmentViewModel {
    private func fetchDepartment() {
        Task {
            isLoading = true
            do {
                let (departments, updatedAt) = try await fetchDepartmentByCategoryUseCase.execute(category: category)
                self.departments = departments
                self.updatedAt = updatedAt
            } catch {
                toastMessage = (error as? ErrorResponse)?.message
            }
            isLoading = false
        }
    }
    
    private func search(keyword: String) {
        searchTask?.cancel()
        searchTask = Task {
            isLoading = true
            do {
                let (departments, updatedAt) = try await searchDepartmentByCategoryUseCase.execute(category: category, keyword: keyword)
                guard !Task.isCancelled else { return }
                self.searchingDepartments = departments
                self.searchingUpdatedAt = updatedAt
            } catch {
                toastMessage = (error as? ErrorResponse)?.message
            }
            isLoading = false
        }
    }
}

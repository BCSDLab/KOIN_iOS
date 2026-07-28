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
        case didShowToast
        case logEvent(EventLabelType, EventParameter.EventCategory, Any)
    }
    
    // MARK: - Properties
    private let fetchDepartmentCategoryUseCase: FetchDepartmentCategoryUseCase
    private let searchDepartmentUseCase: SearchDepartmentUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    
    private(set) var categorys: [DepartmentCategory] = []
    
    private(set) var searchingDepartments: [Department] = []
    private(set) var searchingUpdatedAt: String = ""
    
    private(set) var isLoading: Bool = true
    private var searchTask: Task<Void, Never>?
    
    private(set) var toastMessage: String?
    
    // MARK: - Initializer
    init(
        fetchDepartmentCategoryUseCase: FetchDepartmentCategoryUseCase,
        searchDepartmentUseCase: SearchDepartmentUseCase,
        logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    ) {
        self.fetchDepartmentCategoryUseCase = fetchDepartmentCategoryUseCase
        self.searchDepartmentUseCase = searchDepartmentUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
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
        case .didShowToast:
            toastMessage = nil
        case let .logEvent(label, category, value):
            logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
        }
    }
}

extension DepartmentCategoryViewModel {
    private func fetchCategory() {
        Task {
            isLoading = true
            let categories = try await fetchDepartmentCategoryUseCase.execute()
            self.categorys = categories
            isLoading = false
        }
    }
    
    private func search(keyword: String) {
        searchTask?.cancel()
        searchTask = Task {
            isLoading = true
            do {
                let (departments, updatedAt) = try await searchDepartmentUseCase.execute(keyword: keyword)
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

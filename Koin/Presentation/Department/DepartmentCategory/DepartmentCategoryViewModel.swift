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
    }
    
    // MARK: - Properties
    private let fetchDepartmentCategoryUseCase: FetchDepartmentCategoryUseCase
    
    private(set) var categorys: [DepartmentCategory] = []
    private(set) var updatedAt: String = ""
    
    // MARK: - Initializer
    init(fetchDepartmentCategoryUseCase: FetchDepartmentCategoryUseCase) {
        self.fetchDepartmentCategoryUseCase = fetchDepartmentCategoryUseCase
    }
    
    // MARK: - Execute
    func execute(_ input: Input) {
        switch input {
        case .viewDidAppear:
            fetchCategory()
        }
    }
}

extension DepartmentCategoryViewModel {
    private func fetchCategory() {
        Task {
            let (categories, updatedAt) = await fetchDepartmentCategoryUseCase.execute()
            self.categorys = categories
            self.updatedAt = updatedAt
        }
    }
}

//
//  FetchDepartmentCategoryUseCase.swift
//  koin
//
//  Created by 홍기정 on 7/19/26.
//

import Foundation

protocol FetchDepartmentCategoryUseCase {
    func execute() async -> (categories: [DepartmentCategory], updatedAt: String)
}

final class MockFetchDepartmentCategoryUseCase: FetchDepartmentCategoryUseCase {
    func execute() async -> (categories: [DepartmentCategory], updatedAt: String) {
        let categories: [DepartmentCategory] = [
            .init(id: 1, name: "종류1", icon: .filterIcon3),
            .init(id: 2, name: "종류2", icon: .delete),
            .init(id: 3, name: "종류3", icon: .notificationTrash),
        ]
        let updatedAt = "2022-02-22"
        return (categories, updatedAt)
    }
}

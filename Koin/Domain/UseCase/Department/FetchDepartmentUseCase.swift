//
//  FetchDepartmentUseCase.swift
//  koin
//
//  Created by 홍기정 on 7/19/26.
//

import Foundation

protocol FetchDepartmentUseCase {
    func execute(category: DepartmentCategory) async -> (departments: [Department], updatedAt: String)
}

final class MockFetchDepartmentUseCase: FetchDepartmentUseCase {
    func execute(category: DepartmentCategory) async -> (departments: [Department], updatedAt: String) {
        let departments: [Department] = [
            .init(
                id: 1,
                name: "학지팀",
                tasks: [
                    .init(id: 1, name: "학지팀", phoneNumber: "234-3232-23234"),
                    .init(id: 2, name: "학지팀", phoneNumber: "234-3232-23234"),
                    .init(id: 3, name: "학지팀", phoneNumber: "234-3232-23234")
                ]
            ),
            .init(
                id: 2,
                name: "교지팀",
                tasks: [
                    .init(id: 1, name: "교지팀", phoneNumber: "234-3232-23234"),
                    .init(id: 2, name: "교지팀", phoneNumber: "234-3232-23234")
                ]
            ),
            .init(
                id: 3,
                name: "학부사무실",
                tasks: [
                    .init(id: 1, name: "학부사무실", phoneNumber: "234-3232-23234"),
                ]
            )
        ]
        let updatedAt = "2022-02-22"
        return (departments, updatedAt)
    }
}

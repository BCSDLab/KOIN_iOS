//
//  CloseRecruitMyPostUseCase.swift
//  koin
//
//  Created by 홍기정 on 9/24/26.
//

import Foundation

protocol CloseRecruitMyPostUseCase {
    func execute(id: Int) async throws -> Bool
}

final class DefaultCloseRecruitMyPostUseCase: CloseRecruitMyPostUseCase {

    private let repository: RecruitRepository

    init(repository: RecruitRepository) {
        self.repository = repository
    }

    func execute(id: Int) async throws -> Bool {
        try await repository.closeMyPost(id: id)
    }
}

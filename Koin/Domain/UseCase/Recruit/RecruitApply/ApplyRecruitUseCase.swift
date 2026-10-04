//
//  ApplyRecruitUseCase.swift
//  koin
//
//  Created by 홍기정 on 9/27/26.
//

import Foundation

protocol ApplyRecruitUseCase {
    func execute(recruitmentId: Int, request: RecruitApplyRequest) async throws -> Void
}

final class DefaultApplyRecruitUseCase: ApplyRecruitUseCase {
    private let repository: RecruitRepository

    init(repository: RecruitRepository) {
        self.repository = repository
    }

    func execute(recruitmentId: Int, request: RecruitApplyRequest) async throws -> Void {
        try await repository.apply(recruitmentId: recruitmentId, request)
    }
}

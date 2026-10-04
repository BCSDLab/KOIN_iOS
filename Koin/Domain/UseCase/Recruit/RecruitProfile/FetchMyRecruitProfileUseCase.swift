//
//  FetchMyRecruitProfileUseCase.swift
//  koin
//
//  Created by 홍기정 on 9/13/26.
//

import Foundation

protocol FetchMyRecruitProfileUseCase {
    func execute() async throws -> RecruitProfile?
}

final class DefaultFetchMyRecruitProfileUseCase: FetchMyRecruitProfileUseCase {
    private let repository: RecruitRepository

    init(repository: RecruitRepository) {
        self.repository = repository
    }

    func execute() async throws -> RecruitProfile? {
        do {
            return try await repository.fetchMyProfile()
        } catch let error as ErrorResponse where error.statusCode == 404 {
            return nil
        }
    }
}

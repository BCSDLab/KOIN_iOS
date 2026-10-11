//
//  FetchRecruitDirectChatDataUseCase.swift
//  koin
//
//  Created by 홍기정 on 9/28/26.
//

import Foundation

protocol FetchRecruitDirectChatDataUseCase {
    func execute(
        recruitmentId: Int,
        applicationId: Int
    ) async throws -> RecruitChatData
}

final class DefaultFetchRecruitDirectChatDataUseCase: FetchRecruitDirectChatDataUseCase {

    private let repository: RecruitRepository

    init(repository: RecruitRepository) {
        self.repository = repository
    }

    func execute(
        recruitmentId: Int,
        applicationId: Int
    ) async throws -> RecruitChatData {
        try await repository.fetchDirectChatData(
            recruitmentId: recruitmentId,
            applicationId: applicationId
        )
    }
}

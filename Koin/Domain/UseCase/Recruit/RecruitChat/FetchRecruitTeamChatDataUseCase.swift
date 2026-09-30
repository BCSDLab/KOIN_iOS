//
//  FetchRecruitTeamChatDataUseCase.swift
//  koin
//
//  Created by 홍기정 on 9/28/26.
//

import Foundation

protocol FetchRecruitTeamChatDataUseCase {
    func execute(
        recruitmentId: Int,
        chatRoomId: Int
    ) async throws -> RecruitChatData
}

final class DefaultFetchRecruitTeamChatDataUseCase: FetchRecruitTeamChatDataUseCase {

    private let repository: RecruitRepository

    init(repository: RecruitRepository) {
        self.repository = repository
    }

    func execute(
        recruitmentId: Int,
        chatRoomId: Int
    ) async throws -> RecruitChatData {
        try await repository.fetchTeamChatData(
            recruitmentId: recruitmentId,
            chatRoomId: chatRoomId
        )
    }
}

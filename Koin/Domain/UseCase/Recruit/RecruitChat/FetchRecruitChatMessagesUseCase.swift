//
//  FetchRecruitChatMessagesUseCase.swift
//  koin
//
//  Created by 홍기정 on 9/28/26.
//

import Foundation

protocol FetchRecruitChatMessagesUseCase {
    func execute(
        recruitmentId: Int,
        chatRoomId: Int
    ) async throws -> RecruitChatMessageList
}

final class DefaultFetchRecruitChatMessagesUseCase: FetchRecruitChatMessagesUseCase {

    private let repository: RecruitRepository

    init(repository: RecruitRepository) {
        self.repository = repository
    }

    func execute(
        recruitmentId: Int,
        chatRoomId: Int
    ) async throws -> RecruitChatMessageList {
        try await repository.fetchChatMessages(
            recruitmentId: recruitmentId,
            chatRoomId: chatRoomId
        )
    }
}

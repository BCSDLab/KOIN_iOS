//
//  PostRecruitChatMessageUseCase.swift
//  koin
//
//  Created by 홍기정 on 9/28/26.
//

import Foundation

protocol PostRecruitChatMessageUseCase {
    func execute(
        recruitmentId: Int,
        chatRoomId: Int,
        request: RecruitChatPostRequest
    ) async throws
}

final class DefaultPostRecruitChatMessageUseCase: PostRecruitChatMessageUseCase {

    private let repository: RecruitRepository

    init(repository: RecruitRepository) {
        self.repository = repository
    }

    func execute(
        recruitmentId: Int,
        chatRoomId: Int,
        request: RecruitChatPostRequest
    ) async throws {
        try await repository.postChatMessage(
            recruitmentId: recruitmentId,
            chatRoomId: chatRoomId,
            request: request
        )
    }
}

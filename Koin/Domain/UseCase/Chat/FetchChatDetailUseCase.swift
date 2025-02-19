//
//  FetchChatDetailUseCase.swift
//  koin
//
//  Created by 김나훈 on 2/18/25.
//

import Combine

protocol FetchChatDetailUseCase {
    func execute(userId: Int, articleId: Int, chatRoomId: Int) -> AnyPublisher<[ChatMessage], ErrorResponse>
}
final class DefaultFetchChatDetailUseCase: FetchChatDetailUseCase {
    
    private let chatRepository: ChatRepository
    
    init(chatRepository: ChatRepository) {
        self.chatRepository = chatRepository
    }
    
    func execute(userId: Int, articleId: Int, chatRoomId: Int) -> AnyPublisher<[ChatMessage], ErrorResponse> {
        return chatRepository.fetchChatDetail(articleId: articleId, chatRoomId: chatRoomId)
            .map { dtos in
                dtos.map { $0.toDomain(currentUserId: userId) }
            }
            .eraseToAnyPublisher()
    }
}

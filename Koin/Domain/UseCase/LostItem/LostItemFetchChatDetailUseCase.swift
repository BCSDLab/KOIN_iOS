//
//  LostItemFetchChatDetailUseCase.swift
//  koin
//
//  Created by 김나훈 on 2/18/25.
//

import Combine

protocol LostItemFetchChatDetailUseCase {
    func execute(userId: Int, articleId: Int, chatRoomId: Int) -> AnyPublisher<[LostItemChatMessage], ErrorResponse>
}
final class DefaultLostItemFetchChatDetailUseCase: LostItemFetchChatDetailUseCase {
    
    private let chatRepository: LostItemRepository
    
    init(chatRepository: LostItemRepository) {
        self.chatRepository = chatRepository
    }
    
    func execute(userId: Int, articleId: Int, chatRoomId: Int) -> AnyPublisher<[LostItemChatMessage], ErrorResponse> {
        return chatRepository.fetchChatDetail(articleId: articleId, chatRoomId: chatRoomId)
            .map { dtos in
                dtos.map { $0.toDomain(currentUserId: userId) }
            }
            .eraseToAnyPublisher()
    }
}

//
//  FetchChatDetailUseCase.swift
//  koin
//
//  Created by 김나훈 on 2/18/25.
//

import Combine

protocol FetchChatDetailUseCase {
    func execute(articleId: Int, chatRoomId: Int) -> AnyPublisher<[ChatDetailDTO], ErrorResponse>
}
final class DefaultFetchChatDetailUseCase: FetchChatDetailUseCase {
    
    private let chatRepository: ChatRepository
    
    init(chatRepository: ChatRepository) {
        self.chatRepository = chatRepository
    }
    
    func execute(articleId: Int, chatRoomId: Int) -> AnyPublisher<[ChatDetailDTO], ErrorResponse> {
        return chatRepository.fetchChatDetail(articleId: articleId, chatRoomId: chatRoomId)
    }
}

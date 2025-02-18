//
//  CreateChatRoomUseCase.swift
//  koin
//
//  Created by 김나훈 on 2/18/25.
//

import Combine

protocol CreateChatRoomUseCase {
    func execute(articleId: Int) -> AnyPublisher<CreateChatRoomResponse, ErrorResponse>
}
final class DefaultCreateChatRoomUseCase: CreateChatRoomUseCase {
    
    private let chatRepository: ChatRepository
    
    init(chatRepository: ChatRepository) {
        self.chatRepository = chatRepository
    }
    
    func execute(articleId: Int) -> AnyPublisher<CreateChatRoomResponse, ErrorResponse> {
        return chatRepository.createChatRoom(articleId: articleId)
    }
}


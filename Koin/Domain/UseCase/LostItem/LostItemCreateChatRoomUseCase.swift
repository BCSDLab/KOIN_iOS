//
//  LostItemCreateChatRoomUseCase.swift
//  koin
//
//  Created by 김나훈 on 2/18/25.
//

import Combine

protocol LostItemCreateChatRoomUseCase {
    func execute(articleId: Int) -> AnyPublisher<LostItemCreateChatRoomResponse, ErrorResponse>
}
final class DefaultLostItemCreateChatRoomUseCase: LostItemCreateChatRoomUseCase {
    
    private let chatRepository: LostItemRepository
    
    init(chatRepository: LostItemRepository) {
        self.chatRepository = chatRepository
    }
    
    func execute(articleId: Int) -> AnyPublisher<LostItemCreateChatRoomResponse, ErrorResponse> {
        return chatRepository.createChatRoom(articleId: articleId)
    }
}

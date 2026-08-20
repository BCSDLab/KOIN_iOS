//
//  LostItemBlockUserUseCase.swift
//  koin
//
//  Created by 김나훈 on 2/18/25.
//

import Combine

protocol LostItemBlockUserUseCase {
    func execute(articleId: Int, chatRoomId: Int) -> AnyPublisher<Void, ErrorResponse>
}
final class DefaultLostItemBlockUserUseCase: LostItemBlockUserUseCase {
    
    private let chatRepository: LostItemRepository
    
    init(chatRepository: LostItemRepository) {
        self.chatRepository = chatRepository
    }
    
    func execute(articleId: Int, chatRoomId: Int) -> AnyPublisher<Void, ErrorResponse> {
        return chatRepository.blockUser(articleId: articleId, chatRoomId: chatRoomId)
    }
}

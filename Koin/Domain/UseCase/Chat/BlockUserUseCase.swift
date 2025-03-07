//
//  BlockUserUseCase.swift
//  koin
//
//  Created by 김나훈 on 2/18/25.
//

import Combine

protocol BlockUserUseCase {
    func execute(articleId: Int, chatRoomId: Int) -> AnyPublisher<Void, ErrorResponse>
}
final class DefaultBlockUserUseCase: BlockUserUseCase {
    
    private let chatRepository: ChatRepository
    
    init(chatRepository: ChatRepository) {
        self.chatRepository = chatRepository
    }
    
    func execute(articleId: Int, chatRoomId: Int) -> AnyPublisher<Void, ErrorResponse> {
        return chatRepository.blockUser(articleId: articleId, chatRoomId: chatRoomId)
    }
}

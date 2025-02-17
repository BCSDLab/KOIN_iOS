//
//  FetchChatRoomUseCase.swift
//  koin
//
//  Created by 김나훈 on 2/18/25.
//

import Combine

protocol FetchChatRoomUseCase {
    func execute() -> AnyPublisher<[ChatRoomDTO], ErrorResponse>
}

final class DefaultFetchChatRoomUseCase: FetchChatRoomUseCase {
    let chatRepository: ChatRepository
    
    init(chatRepository: ChatRepository) {
        self.chatRepository = chatRepository
    }
    
    func execute() -> AnyPublisher<[ChatRoomDTO], ErrorResponse> {
        return chatRepository.fetchChatRoom()
    }
}

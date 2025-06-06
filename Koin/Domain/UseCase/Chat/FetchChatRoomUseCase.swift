//
//  FetchChatRoomUseCase.swift
//  koin
//
//  Created by 김나훈 on 2/18/25.
//

import Combine

protocol FetchChatRoomUseCase {
    func execute() -> AnyPublisher<[ChatRoomItem], ErrorResponse>
}

final class DefaultFetchChatRoomUseCase: FetchChatRoomUseCase {
    private let chatRepository: ChatRepository
    
    init(chatRepository: ChatRepository) {
        self.chatRepository = chatRepository
    }
    
    func execute() -> AnyPublisher<[ChatRoomItem], ErrorResponse> {
        return chatRepository.fetchChatRoom()
            .map { $0.map { $0.toDomain() } } 
            .eraseToAnyPublisher()
    }
}

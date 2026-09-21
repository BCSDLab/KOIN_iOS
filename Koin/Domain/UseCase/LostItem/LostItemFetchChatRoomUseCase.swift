//
//  LostItemFetchChatRoomUseCase.swift
//  koin
//
//  Created by 김나훈 on 2/18/25.
//

import Combine

protocol LostItemFetchChatRoomUseCase {
    func execute() -> AnyPublisher<[LostItemChatRoomItem], ErrorResponse>
}

final class DefaultLostItemFetchChatRoomUseCase: LostItemFetchChatRoomUseCase {
    private let chatRepository: LostItemRepository
    
    init(chatRepository: LostItemRepository) {
        self.chatRepository = chatRepository
    }
    
    func execute() -> AnyPublisher<[LostItemChatRoomItem], ErrorResponse> {
        return chatRepository.fetchChatRoom()
            .map { $0.map { $0.toDomain() } } 
            .eraseToAnyPublisher()
    }
}

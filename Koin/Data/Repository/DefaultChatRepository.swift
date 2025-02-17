//
//  DefaultChatRepository.swift
//  koin
//
//  Created by 김나훈 on 2/18/25.
//

import Combine

final class DefaultChatRepository: ChatRepository {

    private let service: ChatService
    
    init(service: ChatService) {
        self.service = service
    }
    
    func fetchChatRoom() -> AnyPublisher<[ChatRoomDTO], ErrorResponse> {
        service.fetchChatRoom()
    }
    
}

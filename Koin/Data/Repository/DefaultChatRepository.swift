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
    
    func createChatRoom(articleId: Int) -> AnyPublisher<CreateChatRoomResponse, ErrorResponse> {
        service.createChatRoom(articleId: articleId)
    }
    
    func blockUser(articleId: Int, chatRoomId: Int) -> AnyPublisher<Void, ErrorResponse> {
        service.blockUser(articleId: articleId, chatRoomId: chatRoomId)
    }
    
    func fetchChatRoom() -> AnyPublisher<[ChatRoomDto], ErrorResponse> {
        service.fetchChatRoom()
    }
    
    func fetchChatDetail(articleId: Int, chatRoomId: Int) -> AnyPublisher<[ChatDetailDto], ErrorResponse> {
        service.fetchChatDetail(articleId: articleId, chatRoomId: chatRoomId)
    }
    
    func postChatDetail(articleId: Int, chatRoomId: Int, request: PostChatDetailRequest) -> AnyPublisher<ChatDetailDto, ErrorResponse> {
        service.postChatDetail(articleId: articleId, chatRoomId: chatRoomId, request: request)
    }
}

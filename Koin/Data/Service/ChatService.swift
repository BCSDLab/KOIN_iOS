//
//  ChatService.swift
//  koin
//
//  Created by 김나훈 on 2/18/25.
//

import Alamofire
import Combine

protocol ChatService {
    func fetchChatRoom() -> AnyPublisher<[ChatRoomDto], ErrorResponse>
    func fetchChatDetail(articleId: Int, chatRoomId: Int) -> AnyPublisher<[ChatDetailDto], ErrorResponse>
    func blockUser(articleId: Int, chatRoomId: Int) -> AnyPublisher<Void, ErrorResponse>
    func createChatRoom(articleId: Int) -> AnyPublisher<CreateChatRoomResponse, ErrorResponse>
    func postChatDetail(articleId: Int, chatRoomId: Int, request: PostChatDetailRequest) -> AnyPublisher<ChatDetailDto, ErrorResponse>
}

final class DefaultChatService: ChatService {
    
    private let networkService = NetworkService()
    
    func createChatRoom(articleId: Int) -> AnyPublisher<CreateChatRoomResponse, ErrorResponse> {
        return networkService.requestWithResponse(api: ChatAPI.createChatRoom(articleId))
    }
    
    func blockUser(articleId: Int, chatRoomId: Int) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: ChatAPI.blockUser(articleId, chatRoomId))
    }
    
    func fetchChatDetail(articleId: Int, chatRoomId: Int) -> AnyPublisher<[ChatDetailDto], ErrorResponse> {
        return networkService.requestWithResponse(api: ChatAPI.fetchChatDetail(articleId, chatRoomId))
    }
    
    func fetchChatRoom() -> AnyPublisher<[ChatRoomDto], ErrorResponse> {
        return networkService.requestWithResponse(api: ChatAPI.fetchChatRoom)
    }
    
    func postChatDetail(articleId: Int, chatRoomId: Int, request: PostChatDetailRequest) -> AnyPublisher<ChatDetailDto, ErrorResponse> {
        return networkService.requestWithResponse(api: ChatAPI.postChatDetail(articleId, chatRoomId, request))
    }
}

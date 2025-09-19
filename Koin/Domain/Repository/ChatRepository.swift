//
//  ChatRepository.swift
//  koin
//
//  Created by 김나훈 on 2/18/25.
//

import Combine

protocol ChatRepository {
    func fetchChatRoom() -> AnyPublisher<[ChatRoomDto], ErrorResponse>
    func fetchChatDetail(articleId: Int, chatRoomId: Int) -> AnyPublisher<[ChatDetailDto], ErrorResponse>
    func blockUser(articleId: Int, chatRoomId: Int) -> AnyPublisher<Void, ErrorResponse>
    func createChatRoom(articleId: Int) -> AnyPublisher<CreateChatRoomResponse, ErrorResponse>
}

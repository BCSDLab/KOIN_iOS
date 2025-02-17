//
//  ChatRepository.swift
//  koin
//
//  Created by 김나훈 on 2/18/25.
//

import Combine

protocol ChatRepository {
    func fetchChatRoom() -> AnyPublisher<[ChatRoomDTO], ErrorResponse>
    func fetchChatDetail(articleId: Int, chatRoomId: Int) -> AnyPublisher<[ChatDetailDTO], ErrorResponse>
}

//
//  PostChatDetailUseCase.swift
//  koin
//
//  Created by 홍기정 on 1/28/26.
//

import Foundation
import Combine

protocol PostChatDetailUseCase {
    func execute(roomId: Int, articleId: Int, message: String, isImage: Bool) -> AnyPublisher<ChatDetailDto, ErrorResponse>
}

final class DefaultPostChatDetailUseCase: PostChatDetailUseCase {
    
    private let chatRepository: ChatRepository
    
    init(chatRepository: ChatRepository) {
        self.chatRepository = chatRepository
    }
    
    func execute(roomId: Int, articleId: Int, message: String, isImage: Bool) -> AnyPublisher<ChatDetailDto, ErrorResponse> {
        let request = PostChatDetailRequest(userNickname: UserDataManager.shared.nickname, content: message, isImage: isImage)
        return chatRepository.postChatDetail(roomId: roomId, articleId: articleId, request: request)
    }
}

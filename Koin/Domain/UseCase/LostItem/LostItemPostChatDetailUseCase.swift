//
//  LostItemPostChatDetailUseCase.swift
//  koin
//
//  Created by 홍기정 on 1/28/26.
//

import Foundation
import Combine

protocol LostItemPostChatDetailUseCase {
    func execute(articleId: Int, chatRoomId: Int, message: String, isImage: Bool) -> AnyPublisher<LostItemChatDetailDto, ErrorResponse>
}

final class DefaultLostItemPostChatDetailUseCase: LostItemPostChatDetailUseCase {
    
    private let chatRepository: LostItemRepository
    
    init(chatRepository: LostItemRepository) {
        self.chatRepository = chatRepository
    }
    
    func execute(articleId: Int, chatRoomId: Int, message: String, isImage: Bool) -> AnyPublisher<LostItemChatDetailDto, ErrorResponse> {
        let request = LostItemPostChatDetailRequest(userNickname: UserDataManager.shared.nickname, content: message, isImage: isImage)
        return chatRepository.postChatDetail(articleId: articleId, chatRoomId: chatRoomId, request: request)
    }
}

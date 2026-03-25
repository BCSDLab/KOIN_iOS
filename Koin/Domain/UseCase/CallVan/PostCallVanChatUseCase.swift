//
//  PostCallVanChatUseCase.swift
//  koin
//
//  Created by 홍기정 on 3/17/26.
//

import Foundation
import Combine

protocol PostCallVanChatUseCase {
    func execute(postId: Int, request: CallVanChatRequest) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultPostCallVanChatUseCase: PostCallVanChatUseCase {
    
    private let repository: CallVanRepository
    
    init(repository: CallVanRepository) {
        self.repository = repository
    }
    
    func execute(postId: Int, request: CallVanChatRequest) -> AnyPublisher<Void, ErrorResponse> {
        return repository.postCallVanChat(postId: postId, request: request)
    }
}

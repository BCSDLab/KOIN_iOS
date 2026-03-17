//
//  FetchCallVanChatUseCase.swift
//  koin
//
//  Created by 홍기정 on 3/17/26.
//

import Foundation
import Combine

protocol FetchCallVanChatUseCase {
    func execute(postId: Int) -> AnyPublisher<CallVanChat, ErrorResponse>
}

final class DefaultFetchCallVanChatUseCase: FetchCallVanChatUseCase {
    
    private let repository: CallVanRepository
    
    init(repository: CallVanRepository) {
        self.repository = repository
    }
    
    func execute(postId: Int) -> AnyPublisher<CallVanChat, ErrorResponse> {
        return repository.fetchCallVanChat(postId: postId)
    }
}

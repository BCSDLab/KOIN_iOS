//
//  CompleteCallVanUseCase.swift
//  koin
//
//  Created by 홍기정 on 3/15/26.
//

import Foundation
import Combine

protocol CompleteCallVanUseCase {
    func execute(postId: Int) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultCompleteCallVanUseCase: CompleteCallVanUseCase {
    
    private let repository: CallVanRepository
    
    init(repository: CallVanRepository) {
        self.repository = repository
    }
    
    func execute(postId: Int) -> AnyPublisher<Void, ErrorResponse> {
        repository.complete(postId: postId)
    }
}

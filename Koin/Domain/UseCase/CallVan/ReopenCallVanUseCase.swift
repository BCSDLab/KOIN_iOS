//
//  ReopenCallVanUseCase.swift
//  koin
//
//  Created by 홍기정 on 3/15/26.
//

import Foundation
import Combine

protocol ReopenCallVanUseCase {
    func execute(postId: Int) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultReopenCallVanUseCase: ReopenCallVanUseCase {
    
    private let repository: CallVanRepository
    
    init(repository: CallVanRepository) {
        self.repository = repository
    }
    
    func execute(postId: Int) -> AnyPublisher<Void, ErrorResponse> {
        repository.reopen(postId: postId)
    }
}

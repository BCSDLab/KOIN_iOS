//
//  CloseCallVanUseCase.swift
//  koin
//
//  Created by 홍기정 on 3/15/26.
//

import Foundation
import Combine

protocol CloseCallVanUseCase {
    func execute(postId: Int) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultCloseCallVanUseCase: CloseCallVanUseCase {
    
    private let repository: CallVanRepository
    
    init(repository: CallVanRepository) {
        self.repository = repository
    }
    
    func execute(postId: Int) -> AnyPublisher<Void, ErrorResponse> {
        repository.close(postId: postId)
    }
}

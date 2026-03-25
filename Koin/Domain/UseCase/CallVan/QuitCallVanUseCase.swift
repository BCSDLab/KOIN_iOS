//
//  QuitCallVanUseCase.swift
//  koin
//
//  Created by 홍기정 on 3/15/26.
//

import Foundation
import Combine

protocol QuitCallVanUseCase {
    func execute(postId: Int) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultQuitCallVanUseCase: QuitCallVanUseCase {
    
    private let repository: CallVanRepository
    
    init(repository: CallVanRepository) {
        self.repository = repository
    }
    
    func execute(postId: Int) -> AnyPublisher<Void, ErrorResponse> {
        repository.quit(postId: postId)
    }
}

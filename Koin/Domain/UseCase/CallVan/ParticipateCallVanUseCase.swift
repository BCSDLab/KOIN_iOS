//
//  ParticipateCallVanUseCase.swift
//  koin
//
//  Created by 홍기정 on 3/15/26.
//

import Foundation
import Combine

protocol ParticipateCallVanUseCase {
    func execute(postId: Int) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultParticipateCallVanUseCase: ParticipateCallVanUseCase {
    
    private let repository: CallVanRepository
    
    init(repository: CallVanRepository) {
        self.repository = repository
    }
    
    func execute(postId: Int) -> AnyPublisher<Void, ErrorResponse> {
        repository.participate(postId: postId)
    }
}

//
//  RevokeUseCase.swift
//  koin
//
//  Created by 김나훈 on 7/27/24.
//

import Combine

protocol RevokeUseCase {
    func execute() -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultRevokeUseCase: RevokeUseCase {
        
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func execute() -> AnyPublisher<Void, ErrorResponse> {
        userRepository.revoke()
    }
    
}

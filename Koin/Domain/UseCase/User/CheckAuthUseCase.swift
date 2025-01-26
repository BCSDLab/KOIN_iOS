//
//  CheckAuthUseCase.swift
//  koin
//
//  Created by 김나훈 on 1/16/25.
//

import Combine

protocol CheckAuthUseCase {
    func execute() -> AnyPublisher<UserTypeResponse, ErrorResponse>
}

final class DefaultCheckAuthUseCase: CheckAuthUseCase {
    
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func execute() -> AnyPublisher<UserTypeResponse, ErrorResponse> {
        return userRepository.checkAuth()
    }
    
}

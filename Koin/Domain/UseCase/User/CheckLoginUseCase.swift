//
//  Untitled.swift
//  koin
//
//  Created by 김나훈 on 2/14/25.
//

import Combine

protocol CheckLoginUseCase {
    func execute() -> AnyPublisher<Bool, Never>
}

final class DefaultCheckLoginUseCase: CheckLoginUseCase {
    
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func execute() -> AnyPublisher<Bool, Never> {
        return userRepository.checkLogin()
    }
    
}

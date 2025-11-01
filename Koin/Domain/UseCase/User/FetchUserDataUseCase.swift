//
//  FetchUserDataUseCase.swift
//  koin
//
//  Created by 김나훈 on 7/25/24.
//

import Combine

protocol FetchUserDataUseCase {
    func execute() -> AnyPublisher<UserDto, ErrorResponse>
}

final class DefaultFetchUserDataUseCase: FetchUserDataUseCase {
        
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func execute() -> AnyPublisher<UserDto, ErrorResponse> {
        userRepository.fetchUserData()
    }
    
}

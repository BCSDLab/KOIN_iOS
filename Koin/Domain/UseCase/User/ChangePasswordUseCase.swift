//
//  ChangePasswordUseCase.swift
//  koin
//
//  Created by 김나훈 on 7/14/25.
//

import Combine

protocol ChangePasswordUseCase {
    func execute(requestModel: ChangePasswordRequest) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultChangePasswordUseCase: ChangePasswordUseCase {
    
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func execute(requestModel: ChangePasswordRequest) -> AnyPublisher<Void, ErrorResponse> {
        return userRepository.changePassword(requestModel: requestModel)
    }
    
}

//
//  CheckPasswordUseCase.swift
//  koin
//
//  Created by 김나훈 on 9/6/24.
//

import Combine

protocol CheckPasswordUseCase {
    func execute(password: String) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultCheckPasswordUseCase: CheckPasswordUseCase {
    
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func execute(password: String) -> AnyPublisher<Void, ErrorResponse> {
        return userRepository.checkPassword(requestModel: CheckPasswordRequest(password: EncodingWorker().sha256(text: password)))
    }
    
}

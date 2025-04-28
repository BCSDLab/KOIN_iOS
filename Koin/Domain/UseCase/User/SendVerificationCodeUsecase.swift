//
//  SendVerificationCodeUsecase.swift
//  koin
//
//  Created by 이은지 on 4/28/25.
//

import Combine

protocol SendVerificationCodeUsecase {
    func execute(phoneNumber: String) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultSendVerificationCodeUseCase: SendVerificationCodeUsecase {
    
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func execute(phoneNumber: String) -> AnyPublisher<Void, ErrorResponse> {
        return userRepository.sendVerificationCode(requestModel: SendVerificationCodeRequest(phoneNumber: phoneNumber))
    }
    
}

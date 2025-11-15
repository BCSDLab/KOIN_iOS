//
//  SendVerificationCodeUsecase.swift
//  koin
//
//  Created by 이은지 on 4/28/25.
//

import Combine

protocol SendVerificationCodeUsecase {
    func execute(request: SendVerificationCodeRequest) -> AnyPublisher<SendVerificationCodeDto, ErrorResponse>
}

final class DefaultSendVerificationCodeUseCase: SendVerificationCodeUsecase {
    
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func execute(request: SendVerificationCodeRequest) -> AnyPublisher<SendVerificationCodeDto, ErrorResponse> {
        return userRepository.sendVerificationCode(requestModel: request)
    }
    
}

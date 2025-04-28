//
//  CheckVerificationCodeUsecase.swift
//  koin
//
//  Created by 이은지 on 4/28/25.
//

import Combine

protocol CheckVerificationCodeUsecase {
    func execute(phoneNumber: String, verificationCode: String) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultCheckVerificationCodeUsecase: CheckVerificationCodeUsecase {
    
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func execute(phoneNumber: String, verificationCode: String) -> AnyPublisher<Void, ErrorResponse> {
        return userRepository.checkVerificationCode(requestModel: CheckVerificationCodeRequest(phoneNumber: phoneNumber, verificationCode: verificationCode))
    }
    
}

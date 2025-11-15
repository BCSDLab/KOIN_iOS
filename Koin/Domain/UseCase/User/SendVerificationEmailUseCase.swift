//
//  SendVerificationEmailUseCase.swift
//  koin
//
//  Created by 김나훈 on 6/18/25.
//

import Combine

protocol SendVerificationEmailUseCase {
    func execute(requestModel: SendVerificationEmailRequest) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultSendVerificationEmailUseCase: SendVerificationEmailUseCase {
    
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func execute(requestModel: SendVerificationEmailRequest) -> AnyPublisher<Void, ErrorResponse> {
        return userRepository.sendVerificationEmail(requestModel: requestModel)
    }
    
}

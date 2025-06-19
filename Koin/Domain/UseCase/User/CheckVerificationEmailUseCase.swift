//
//  CheckVerificationEmailUseCase.swift
//  koin
//
//  Created by 김나훈 on 6/18/25.
//

import Combine

protocol CheckVerificationEmailUseCase {
    func execute(requestModel: CheckVerificationEmailRequest) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultCheckVerificationEmailUseCase: CheckVerificationEmailUseCase {
    
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func execute(requestModel: CheckVerificationEmailRequest) -> AnyPublisher<Void, ErrorResponse> {
        return userRepository.checkVerificationEmail(requestModel: requestModel)
    }
    
}

//
//  ResetPasswordEmailUseCase.swift
//  koin
//
//  Created by 김나훈 on 6/19/25.
//


import Combine

protocol ResetPasswordEmailUseCase {
    func execute(requestModel: ResetPasswordEmailRequest) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultResetPasswordEmailUseCase: ResetPasswordEmailUseCase {
    
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func execute(requestModel: ResetPasswordEmailRequest) -> AnyPublisher<Void, ErrorResponse> {
        return userRepository.resetPasswordEmail(requestModel: .init(loginId: requestModel.loginId, email: requestModel.email, newPassword: EncodingWorker().sha256(text: requestModel.newPassword)))
    }
    
}

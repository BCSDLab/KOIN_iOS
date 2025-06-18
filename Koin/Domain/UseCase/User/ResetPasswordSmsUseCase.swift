//
//  ResetPasswordSmsUseCase.swift
//  koin
//
//  Created by 김나훈 on 6/19/25.
//

import Combine

protocol ResetPasswordSmsUseCase {
    func execute(requestModel: ResetPasswordSmsRequest) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultResetPasswordSmsUseCase: ResetPasswordSmsUseCase {
    
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func execute(requestModel: ResetPasswordSmsRequest) -> AnyPublisher<Void, ErrorResponse> {
        return userRepository.resetPasswordSms(requestModel: .init(loginId: requestModel.loginId, phoneNumber: requestModel.phoneNumber, newPassword: EncodingWorker().sha256(text: requestModel.newPassword)))
    }
    
}

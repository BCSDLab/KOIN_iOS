//
//  FindPasswordViewModel.swift
//  koin
//
//  Created by 김나훈 on 3/24/24.
//

import Combine

final class FindPasswordViewModel {
    
    // MARK: - Properties
    
    private var subscriptions: Set<AnyCancellable> = []
    private let userRepository = DefaultUserRepository(service: DefaultUserService())
    private lazy var findPasswordEmailUseCase = DefaultResetPasswordEmailUseCase(userRepository: userRepository)
    private lazy var findPasswordSmsUseCase = DefaultResetPasswordSmsUseCase(userRepository: userRepository)
    private lazy var sendVerificationCodeUseCase = DefaultSendVerificationCodeUseCase(userRepository: userRepository)
    private lazy var checkVerificationCodeUseCase = DefaultCheckVerificationCodeUsecase(userRepository: userRepository)
    private lazy var sendVerificationEmailUseCase = DefaultSendVerificationEmailUseCase(userRepository: userRepository)
    private lazy var checkVerificationEmailUseCase = DefaultCheckVerificationEmailUseCase(userRepository: userRepository)
    
}

extension FindPasswordViewModel {

}

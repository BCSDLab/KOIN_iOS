//
//  LoginUseCase.swift
//  koin
//
//  Created by 김나훈 on 7/23/24.
//

import Combine

protocol LoginUseCase {
    func execute(loginId: String, loginPw: String) -> AnyPublisher<TokenDto, ErrorResponse>
}

final class DefaultLoginUseCase: LoginUseCase {
    
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func execute(loginId: String, loginPw: String) -> AnyPublisher<TokenDto, ErrorResponse> {
        return userRepository.login(requestModel: LoginRequest(loginId: loginId, loginPw: EncodingWorker().sha256(text: loginPw)))
    }
    
}

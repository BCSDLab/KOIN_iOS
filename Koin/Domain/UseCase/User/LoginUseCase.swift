//
//  LoginUseCase.swift
//  koin
//
//  Created by 김나훈 on 7/23/24.
//

import Combine

protocol LoginUseCase {
    func execute(email: String, password: String) -> AnyPublisher<TokenDTO, ErrorResponse>
}

final class DefaultLoginUseCase: LoginUseCase {
    
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func execute(email: String, password: String) -> AnyPublisher<TokenDTO, ErrorResponse> {
        return userRepository.login(requestModel: LoginRequest(email: "\(email)@koreatech.ac.kr", password: EncodingWorker().sha256(text: password)))
    }
    
}

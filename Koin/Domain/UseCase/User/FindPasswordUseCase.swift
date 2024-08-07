//
//  FindPasswordUseCase.swift
//  koin
//
//  Created by 김나훈 on 7/22/24.
//

import Combine

protocol FindPasswordUseCase {
    func execute(email: String) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultFindPasswordUseCase: FindPasswordUseCase {
    
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func execute(email: String) -> AnyPublisher<Void, ErrorResponse> {
        return userRepository.findPassword(requestModel: FindPasswordRequest(email: "\(email)@koreatech.ac.kr"))
    }
    
}

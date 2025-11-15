//
//  CheckDuplicatedIdUsecase.swift
//  koin
//
//  Created by 이은지 on 4/30/25.
//

import Combine

protocol CheckDuplicatedIdUsecase {
    func execute(loginId: String) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultCheckDuplicatedIdUsecase: CheckDuplicatedIdUsecase {
    
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func execute(loginId: String) -> AnyPublisher<Void, ErrorResponse> {
        return userRepository.checkDuplicatedId(requestModel: CheckDuplicatedIdRequest(loginId: loginId))
    }
    
}

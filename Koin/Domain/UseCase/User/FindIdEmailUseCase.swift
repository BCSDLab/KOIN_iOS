//
//  FindIdEmailUseCase.swift
//  koin
//
//  Created by 김나훈 on 6/18/25.
//

import Combine

protocol FindIdEmailUseCase {
    func execute(requestModel: FindIdEmailRequest) -> AnyPublisher<FindIdEmailResponse, ErrorResponse>
}

final class DefaultFindIdEmailUseCase: FindIdEmailUseCase {
    
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func execute(requestModel: FindIdEmailRequest) -> AnyPublisher<FindIdEmailResponse, ErrorResponse> {
        return userRepository.findIdEmail(requestModel: requestModel)
    }
    
}

//
//  FindIdSmsUseCase.swift
//  koin
//
//  Created by 김나훈 on 6/18/25.
//

import Combine

protocol FindIdSmsUseCase {
    func execute(requestModel: FindIdSmsRequest) -> AnyPublisher<FindIdSmsResponse, ErrorResponse>
}

final class DefaultFindIdSmsUseCase: FindIdSmsUseCase {
    
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func execute(requestModel: FindIdSmsRequest) -> AnyPublisher<FindIdSmsResponse, ErrorResponse> {
        return userRepository.findIdSms(requestModel: requestModel)
    }
    
}

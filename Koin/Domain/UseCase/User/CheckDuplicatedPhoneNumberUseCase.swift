//
//  CheckDuplicatedPhoneNumberUseCase.swift
//  koin
//
//  Created by 이은지 on 4/27/25.
//

import Combine

protocol CheckDuplicatedPhoneNumberUseCase {
    func execute(phone: String) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultCheckDuplicatedPhoneNumberUseCase: CheckDuplicatedPhoneNumberUseCase {
    
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func execute(phone: String) -> AnyPublisher<Void, ErrorResponse> {
        return userRepository.checkDuplicatedPhoneNumber(requestModel: CheckDuplicatedPhoneNumberRequest(phone: phone))
    }
    
}

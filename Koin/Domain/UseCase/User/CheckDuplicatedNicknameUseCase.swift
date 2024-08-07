//
//  CheckDuplicatedNicknameUseCase.swift
//  koin
//
//  Created by 김나훈 on 7/22/24.
//

import Combine

protocol CheckDuplicatedNicknameUseCase {
    func execute(nickname: String) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultCheckDuplicatedNicknameUseCase: CheckDuplicatedNicknameUseCase {
    
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func execute(nickname: String) -> AnyPublisher<Void, ErrorResponse> {
        return userRepository.checkDuplicatedNickname(requestModel: CheckDuplicatedNicknameRequest(nickname: nickname))
    }
    
}

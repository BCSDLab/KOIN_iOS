//
//  ModifyUseCase.swift
//  koin
//
//  Created by 김나훈 on 7/27/24.
//

import Combine

protocol ModifyUseCase {
    func execute(requestModel: UserPutRequest) -> AnyPublisher<UserDTO, ErrorResponse>
}

final class DefaultModifyUseCase: ModifyUseCase {
    
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func execute(requestModel: UserPutRequest) -> AnyPublisher<UserDTO, ErrorResponse> {
        var mutableRequestModel = requestModel
        mutableRequestModel.sha256()
        return userRepository.modify(requestModel: mutableRequestModel)
    }
    
    
}

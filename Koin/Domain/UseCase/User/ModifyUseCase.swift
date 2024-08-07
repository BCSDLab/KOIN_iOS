//
//  ModifyUseCase.swift
//  koin
//
//  Created by 김나훈 on 7/27/24.
//

import Combine

protocol ModifyUseCase {
    func execute(requestModel: UserPutRequest, passwordMatch: String) -> AnyPublisher<UserDTO, ErrorResponse>
}

final class DefaultModifyUseCase: ModifyUseCase {
    
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func execute(requestModel: UserPutRequest, passwordMatch: String) -> AnyPublisher<UserDTO, ErrorResponse> {
        if let password = requestModel.password, password != "" {
            let passwordCheckResult = checkValidPasswordInput(password: password, passwordMatch: passwordMatch)
            switch passwordCheckResult {
            case .success:
                var mutableRequestModel = requestModel
                mutableRequestModel.sha256()
                return userRepository.modify(requestModel: mutableRequestModel)
            case .failure(let error):
                return Fail(error: ErrorResponse(code: "", message: error.localizedDescription))
                    .eraseToAnyPublisher()
            }
        } else {
            return userRepository.modify(requestModel: requestModel)
        }
    }
    
    private func checkValidPasswordInput(password: String, passwordMatch: String) -> Result<Void, UserInputError> {
        return PasswordConfirmer(passwordMatchText: passwordMatch).confirm(text: password)
    }
    
}

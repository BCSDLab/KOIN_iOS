//
//  RegisterUseCase.swift
//  koin
//
//  Created by 김나훈 on 7/22/24.
//

import Combine

protocol RegisterUseCase {
    func execute(requestModel: UserRegisterRequest, passwordMatch: String) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultRegisterUseCase: RegisterUseCase {
    
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func execute(requestModel: UserRegisterRequest, passwordMatch: String) -> AnyPublisher<Void, ErrorResponse> {
        let passwordCheckResult = checkValidPasswordInput(password: requestModel.password, passwordMatch: passwordMatch)
        
        switch passwordCheckResult {
        case .success:
            var mutableRequestModel = requestModel
            mutableRequestModel.sha256()
            return userRepository.register(requestModel: mutableRequestModel)
        case .failure(let error):
            return Fail(error: ErrorResponse(code: "", message: error.localizedDescription))
                .eraseToAnyPublisher()
        }
    }
    
    private func checkValidPasswordInput(password: String, passwordMatch: String) -> Result<Void, UserInputError> {
        return PasswordConfirmer(passwordMatchText: passwordMatch).confirm(text: password)
    }
    
}

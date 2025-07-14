//
//  RegisterFormUseCase.swift
//  koin
//
//  Created by 이은지 on 5/7/25.
//

import Combine

protocol RegisterFormUseCase {
    func studentExecute(name: String, phoneNumber: String, loginId: String, password: String, department: String, studentNumber: String, gender: String, email: String?, nickname: String?) -> AnyPublisher<Void, ErrorResponse>
    func generalExecute(name: String, phoneNumber: String, loginId: String, gender: String, password: String, email: String?, nickname: String?) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultRegisterFormUseCase: RegisterFormUseCase {
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func studentExecute(name: String, phoneNumber: String, loginId: String, password: String, department: String, studentNumber: String, gender: String, email: String?, nickname: String?) -> AnyPublisher<Void, ErrorResponse> {
        return userRepository.studentRegisterForm(requestModel: StudentRegisterFormRequest(name: name, phoneNumber: phoneNumber, loginId: loginId, password: password, department: department, studentNumber: studentNumber, gender: gender, email: email, nickname: nickname))
    }
    
    func generalExecute(name: String, phoneNumber: String, loginId: String, gender: String, password: String, email: String?, nickname: String?) -> AnyPublisher<Void, ErrorResponse> {
        return userRepository.generalRegisterForm(requestModel: GeneralRegisterFormRequest(name: name, phoneNumber: phoneNumber, loginId: loginId, gender: gender, password: password, email: email, nickname: nickname))
    }
}

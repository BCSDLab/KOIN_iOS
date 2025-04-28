//
//  DefaultUserRepository.swift
//  koin
//
//  Created by 김나훈 on 7/22/24.
//

import Combine

final class DefaultUserRepository: UserRepository {
    
    private let service: UserService
    
    init(service: UserService) {
        self.service = service
    }
    
    func checkAuth() -> AnyPublisher<UserTypeResponse, ErrorResponse> {
        service.checkAuth()
    }
    
    func fetchUserData() -> AnyPublisher<UserDTO, ErrorResponse> {
        service.fetchUserData()
    }
    
    func modify(requestModel: UserPutRequest) -> AnyPublisher<UserDTO, ErrorResponse> {
        service.modify(requestModel: requestModel)
    }
    
    func register(requestModel: UserRegisterRequest) -> AnyPublisher<Void, ErrorResponse> {
        service.register(requestModel: requestModel)
    }
    
    func login(requestModel: LoginRequest) -> AnyPublisher<TokenDTO, ErrorResponse> {
        service.login(requestModel: requestModel)
    }
    
    func logout() -> AnyPublisher<String, Error> {
        let fakeResponse = ""
        return Just(fakeResponse).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func findPassword(requestModel: FindPasswordRequest) -> AnyPublisher<Void, ErrorResponse> {
        service.findPassword(requestModel: requestModel)
    }
    
    func checkDuplicatedPhoneNumber(requestModel: CheckDuplicatedPhoneNumberRequest) -> AnyPublisher<Void, ErrorResponse> {
        service.checkDuplicatedPhoneNumber(requestModel: requestModel)
    }
    
    func checkDuplicatedNickname(requestModel: CheckDuplicatedNicknameRequest) -> AnyPublisher<Void, ErrorResponse> {
        service.checkDuplicatedNickname(requestModel: requestModel)
    }
    
    func checkDuplicatedEmail(email: String) -> AnyPublisher<String, Error> {
        let fakeResponse = ""
        return Just(fakeResponse).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func revoke() -> AnyPublisher<Void, ErrorResponse> {
        service.revoke()
    }
    
    func checkPassword(requestModel: CheckPasswordRequest) -> AnyPublisher<Void, ErrorResponse> {
        service.checkPassword(requestModel: requestModel)
    }
    
    func checkLogin() -> AnyPublisher<Bool, Never> {
        service.checkLogin()
    }
    
    func sendVerificationCode(requestModel: SendVerificationCodeRequest) -> AnyPublisher<SendVerificationCodeDTO, ErrorResponse> {
        service.sendVerificationCode(requestModel: requestModel)
    }
    
    func checkVerificationCode(requestModel: CheckVerificationCodeRequest) -> AnyPublisher<Void, ErrorResponse> {
        service.checkVerificationCode(requestModel: requestModel)
    }
}

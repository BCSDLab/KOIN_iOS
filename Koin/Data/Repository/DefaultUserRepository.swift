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
    
    func changePassword(requestModel: ChangePasswordRequest) -> AnyPublisher<Void, ErrorResponse> {
        service.changePassword(requestModel: requestModel)
    }
    
    func resetPasswordSms(requestModel: ResetPasswordSmsRequest) -> AnyPublisher<Void, ErrorResponse> {
        service.resetPasswordSms(requestModel: requestModel)
    }
    
    func resetPasswordEmail(requestModel: ResetPasswordEmailRequest) -> AnyPublisher<Void, ErrorResponse> {
        service.resetPasswordEmail(requestModel: requestModel)
    }
    
    func findIdSms(requestModel: FindIdSmsRequest) -> AnyPublisher<FindIdSmsResponse, ErrorResponse> {
        service.findIdSms(requestModel: requestModel)
    }
    
    func findIdEmail(requestModel: FindIdEmailRequest) -> AnyPublisher<FindIdEmailResponse, ErrorResponse> {
        service.findIdEmail(requestModel: requestModel)
    }
    
    func sendVerificationEmail(requestModel: SendVerificationEmailRequest) -> AnyPublisher<Void, ErrorResponse> {
        service.sendVerificationEmail(requestModel: requestModel)
    }
    
    func checkVerificationEmail(requestModel: CheckVerificationEmailRequest) -> AnyPublisher<Void, ErrorResponse> {
        service.checkVerificationEmail(requestModel: requestModel)
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
    
    func checkDuplicatedId(requestModel: CheckDuplicatedIdRequest) -> AnyPublisher<Void, ErrorResponse> {
        service.checkDuplicatedId(requestModel: requestModel)
    }
    
    func studentRegisterForm(requestModel: StudentRegisterFormRequest) -> AnyPublisher<Void, ErrorResponse> {
        service.studentRegisterForm(requestModel: requestModel)
    }
    
    func generalRegisterForm(requestModel: GeneralRegisterFormRequest) -> AnyPublisher<Void, ErrorResponse> {
        service.generalRegisterForm(requestModel: requestModel)
    }
}

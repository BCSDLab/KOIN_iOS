//
//  UserService.swift
//  koin
//
//  Created by 김나훈 on 7/22/24.
//

import Alamofire
import Combine

protocol UserService {
    func findPassword(requestModel: FindPasswordRequest) -> AnyPublisher<Void, ErrorResponse>
    func register(requestModel: UserRegisterRequest) -> AnyPublisher<Void, ErrorResponse>
    func checkDuplicatedPhoneNumber(requestModel: CheckDuplicatedPhoneNumberRequest) -> AnyPublisher<Void, ErrorResponse>
    func checkDuplicatedNickname(requestModel: CheckDuplicatedNicknameRequest) -> AnyPublisher<Void, ErrorResponse>
    func login(requestModel: LoginRequest) -> AnyPublisher<TokenDto, ErrorResponse>
    func fetchUserData() -> AnyPublisher<UserDto, ErrorResponse>
    func revoke() -> AnyPublisher<Void, ErrorResponse>
    func modify(requestModel: UserPutRequest) -> AnyPublisher<UserDto, ErrorResponse>
    func checkPassword(requestModel: CheckPasswordRequest) -> AnyPublisher<Void, ErrorResponse>
    func checkAuth() -> AnyPublisher<UserTypeResponse, ErrorResponse>
    func checkLogin() -> AnyPublisher<Bool, Never>
    func sendVerificationCode(requestModel: SendVerificationCodeRequest) -> AnyPublisher<SendVerificationCodeDto, ErrorResponse>
    func checkVerificationCode(requestModel: CheckVerificationCodeRequest) -> AnyPublisher<Void, ErrorResponse>
    func checkDuplicatedId(requestModel: CheckDuplicatedIdRequest) -> AnyPublisher<Void, ErrorResponse>
    func studentRegisterForm(requestModel: StudentRegisterFormRequest) -> AnyPublisher<Void, ErrorResponse>
    func generalRegisterForm(requestModel: GeneralRegisterFormRequest) -> AnyPublisher<Void, ErrorResponse>
    func sendVerificationEmail(requestModel: SendVerificationEmailRequest) -> AnyPublisher<Void, ErrorResponse>
    func checkVerificationEmail(requestModel: CheckVerificationEmailRequest) -> AnyPublisher<Void, ErrorResponse>
    func findIdSms(requestModel: FindIdSmsRequest) -> AnyPublisher<FindIdSmsResponse, ErrorResponse>
    func findIdEmail(requestModel: FindIdEmailRequest) -> AnyPublisher<FindIdEmailResponse, ErrorResponse>
    func resetPasswordSms(requestModel: ResetPasswordSmsRequest) -> AnyPublisher<Void, ErrorResponse>
    func resetPasswordEmail(requestModel: ResetPasswordEmailRequest) -> AnyPublisher<Void, ErrorResponse>
    func changePassword(requestModel: ChangePasswordRequest) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultUserService: UserService {
    
    private let networkService = NetworkService.shared
    
    func changePassword(requestModel: ChangePasswordRequest) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: UserAPI.changePassword(requestModel))
    }
    
    func resetPasswordSms(requestModel: ResetPasswordSmsRequest) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: UserAPI.resetPasswordSms(requestModel))
    }

    func resetPasswordEmail(requestModel: ResetPasswordEmailRequest) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: UserAPI.resetPasswordEmail(requestModel))
    }
    
    func findIdSms(requestModel: FindIdSmsRequest) -> AnyPublisher<FindIdSmsResponse, ErrorResponse> {
        return networkService.requestWithResponse(api: UserAPI.findIdSms(requestModel))
    }
    
    func findIdEmail(requestModel: FindIdEmailRequest) -> AnyPublisher<FindIdEmailResponse, ErrorResponse> {
        return networkService.requestWithResponse(api: UserAPI.findIdEmail(requestModel))
    }
    
    func sendVerificationEmail(requestModel: SendVerificationEmailRequest) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: UserAPI.sendVerificationEmail(requestModel))
    }
    
    func checkVerificationEmail(requestModel: CheckVerificationEmailRequest) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: UserAPI.checkVerificationEmail(requestModel))
    }
    
    func checkLogin() -> AnyPublisher<Bool, Never> {
        return (networkService.request(api: UserAPI.checkLogin) as AnyPublisher<Void, ErrorResponse>)
            .map { _ in true }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }
    
    func checkAuth() -> AnyPublisher<UserTypeResponse, ErrorResponse> {
        return networkService.requestWithResponse(api: UserAPI.checkAuth)
    }
    
    func findPassword(requestModel: FindPasswordRequest) -> AnyPublisher<Void, ErrorResponse> {
        networkService.request(api: UserAPI.findPassword(requestModel))
    }
    
    func register(requestModel: UserRegisterRequest) -> AnyPublisher<Void, ErrorResponse> {
        networkService.request(api: UserAPI.register(requestModel))
    }
    
    func checkDuplicatedPhoneNumber(requestModel: CheckDuplicatedPhoneNumberRequest) -> AnyPublisher<Void, ErrorResponse> {
        networkService.request(api: UserAPI.checkDuplicatedPhoneNumber(requestModel))
    }
    
    func checkDuplicatedNickname(requestModel: CheckDuplicatedNicknameRequest) -> AnyPublisher<Void, ErrorResponse> {
        networkService.request(api: UserAPI.checkDuplicatedNickname(requestModel))
    }
    
    func login(requestModel: LoginRequest) -> AnyPublisher<TokenDto, ErrorResponse> {
        networkService.requestWithResponse(api: UserAPI.login(requestModel))
    }
    
    func fetchUserData() -> AnyPublisher<UserDto, ErrorResponse> {
        return (networkService.requestWithResponse(api: UserAPI.checkAuth) as AnyPublisher<UserTypeResponse, ErrorResponse>)
            .flatMap { [weak self] userTypeResponse -> AnyPublisher<UserDto, ErrorResponse> in
                guard let self = self else { return Empty().eraseToAnyPublisher() }
                let userType = userTypeResponse.userType
                let api: UserAPI = userType == .student ? .fetchStudentUserData : .fetchGeneralUserData
                return self.networkService.requestWithResponse(api: api)
            }.eraseToAnyPublisher()
    }
    
    func revoke() -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: UserAPI.revoke)
    }
    
    func modify(requestModel: UserPutRequest) -> AnyPublisher<UserDto, ErrorResponse> {
        return (networkService.requestWithResponse(api: UserAPI.checkAuth) as AnyPublisher<UserTypeResponse, ErrorResponse>)
            .flatMap { [weak self] userTypeResponse -> AnyPublisher<UserDto, ErrorResponse> in
                guard let self = self else { return Empty().eraseToAnyPublisher() }
                let userType = userTypeResponse.userType
                let api: UserAPI = userType == .student ? .modifyStudentUserData(requestModel) : .modifyGeneralUserData(requestModel)
                return self.networkService.requestWithResponse(api: api)
            }
            .eraseToAnyPublisher()
    }
    
    func checkPassword(requestModel: CheckPasswordRequest) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: UserAPI.checkPassword(requestModel))
    }
    
    func sendVerificationCode(requestModel: SendVerificationCodeRequest) -> AnyPublisher<SendVerificationCodeDto, ErrorResponse> {
        return networkService.requestWithResponse(api: UserAPI.sendVerificationCode(requestModel))
    }
    
    func checkVerificationCode(requestModel: CheckVerificationCodeRequest) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: UserAPI.checkVerificationCode(requestModel))
    }
    
    func checkDuplicatedId(requestModel: CheckDuplicatedIdRequest) -> AnyPublisher<Void, ErrorResponse> {
        networkService.request(api: UserAPI.checkDuplicatedId(requestModel))
    }
    
    func studentRegisterForm(requestModel: StudentRegisterFormRequest) -> AnyPublisher<Void, ErrorResponse> {
        networkService.request(api: UserAPI.studentRegisterForm(requestModel))
    }
    
    func generalRegisterForm(requestModel: GeneralRegisterFormRequest) -> AnyPublisher<Void, ErrorResponse> {
        networkService.request(api: UserAPI.generalRegisterForm(requestModel))
    }
}

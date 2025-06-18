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
    func login(requestModel: LoginRequest) -> AnyPublisher<TokenDTO, ErrorResponse>
    func fetchUserData() -> AnyPublisher<UserDTO, ErrorResponse>
    func revoke() -> AnyPublisher<Void, ErrorResponse>
    func modify(requestModel: UserPutRequest) -> AnyPublisher<UserDTO, ErrorResponse>
    func checkPassword(requestModel: CheckPasswordRequest) -> AnyPublisher<Void, ErrorResponse>
    func checkAuth() -> AnyPublisher<UserTypeResponse, ErrorResponse>
    func checkLogin() -> AnyPublisher<Bool, Never>
    func sendVerificationCode(requestModel: SendVerificationCodeRequest) -> AnyPublisher<SendVerificationCodeDTO, ErrorResponse>
    func checkVerificationCode(requestModel: CheckVerificationCodeRequest) -> AnyPublisher<Void, ErrorResponse>
    func checkDuplicatedId(requestModel: CheckDuplicatedIdRequest) -> AnyPublisher<Void, ErrorResponse>
    func studentRegisterForm(requestModel: StudentRegisterFormRequest) -> AnyPublisher<Void, ErrorResponse>
    func generalRegisterForm(requestModel: GeneralRegisterFormRequest) -> AnyPublisher<Void, ErrorResponse>
    func sendVerificationEmail(requestModel: SendVerificationEmailRequest) -> AnyPublisher<Void, ErrorResponse>
    func checkVerificationEmail(requestModel: CheckVerificationEmailRequest) -> AnyPublisher<Void, ErrorResponse>
    func findIdSms(requestModel: FindIdSmsRequest) -> AnyPublisher<FindIdSmsResponse, ErrorResponse>
    func findIdEmail(requestModel: FindIdEmailRequest) -> AnyPublisher<FindIdEmailResponse, ErrorResponse>
}

final class DefaultUserService: UserService {
    
    
    private let networkService = NetworkService()
    
    func findIdSms(requestModel: FindIdSmsRequest) -> AnyPublisher<FindIdSmsResponse, ErrorResponse> {
        return networkService.requestWithResponse(api: UserAPI.findIdSms(requestModel))
            .catch { [weak self] error -> AnyPublisher<FindIdSmsResponse, ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.requestWithResponse(api: UserAPI.findIdSms(requestModel)) }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func findIdEmail(requestModel: FindIdEmailRequest) -> AnyPublisher<FindIdEmailResponse, ErrorResponse> {
        return networkService.requestWithResponse(api: UserAPI.findIdEmail(requestModel))
            .catch { [weak self] error -> AnyPublisher<FindIdEmailResponse, ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.requestWithResponse(api: UserAPI.findIdEmail(requestModel)) }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func sendVerificationEmail(requestModel: SendVerificationEmailRequest) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: UserAPI.sendVerificationEmail(requestModel))
            .catch { [weak self] error -> AnyPublisher<Void, ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.request(api: UserAPI.sendVerificationEmail(requestModel)) }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func checkVerificationEmail(requestModel: CheckVerificationEmailRequest) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: UserAPI.checkVerificationEmail(requestModel))
            .catch { [weak self] error -> AnyPublisher<Void, ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.request(api: UserAPI.checkVerificationEmail(requestModel)) }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func checkLogin() -> AnyPublisher<Bool, Never> {
        networkService.request(api: UserAPI.checkLogin)
            .map { _ in true } 
            .catch { [weak self] error -> AnyPublisher<Bool, Never> in
                guard let self = self else {
                    return Just(false).eraseToAnyPublisher()
                }
                if error.code == "401" {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.request(api: UserAPI.checkLogin) }
                        .map { _ in true }
                        .replaceError(with: false)
                        .eraseToAnyPublisher()
                } else {
                    return Just(false).eraseToAnyPublisher()
                }
            }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }

    func checkAuth() -> AnyPublisher<UserTypeResponse, ErrorResponse> {
        return networkService.requestWithResponse(api: UserAPI.checkAuth)
            .catch { [weak self] error -> AnyPublisher<UserTypeResponse, ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.requestWithResponse(api: UserAPI.checkAuth) }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
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
    
    func login(requestModel: LoginRequest) -> AnyPublisher<TokenDTO, ErrorResponse> {
        networkService.requestWithResponse(api: UserAPI.login(requestModel))
    }
    
    func fetchUserData() -> AnyPublisher<UserDTO, ErrorResponse> {
        return networkService.requestWithResponse(api: UserAPI.fetchUserData)
            .catch { [weak self] error -> AnyPublisher<UserDTO, ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.requestWithResponse(api: UserAPI.fetchUserData) }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func revoke() -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: UserAPI.revoke)
            .catch { [weak self] error -> AnyPublisher<Void, ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.request(api: UserAPI.revoke) }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func modify(requestModel: UserPutRequest) -> AnyPublisher<UserDTO, ErrorResponse> {
        return networkService.requestWithResponse(api: UserAPI.modify(requestModel))
            .catch { [weak self] error -> AnyPublisher<UserDTO, ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.requestWithResponse(api: UserAPI.modify(requestModel)) }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func checkPassword(requestModel: CheckPasswordRequest) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: UserAPI.checkPassword(requestModel))
            .catch { [weak self] error -> AnyPublisher<Void, ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.request(api: UserAPI.checkPassword(requestModel)) }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func sendVerificationCode(requestModel: SendVerificationCodeRequest) -> AnyPublisher<SendVerificationCodeDTO, ErrorResponse> {
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

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
    func checkDuplicatedNickname(requestModel: CheckDuplicatedNicknameRequest) -> AnyPublisher<Void, ErrorResponse>
    func login(requestModel: LoginRequest) -> AnyPublisher<TokenDTO, ErrorResponse>
    func fetchUserData() -> AnyPublisher<UserDTO, ErrorResponse>
    func revoke() -> AnyPublisher<Void, ErrorResponse>
    func modify(requestModel: UserPutRequest) -> AnyPublisher<UserDTO, ErrorResponse>
    func checkPassword(requestModel: CheckPasswordRequest) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultUserService: UserService {
    private let networkService = NetworkService()
    
    func findPassword(requestModel: FindPasswordRequest) -> AnyPublisher<Void, ErrorResponse> {
        networkService.request(api: UserAPI.findPassword(requestModel))
    }
    
    func register(requestModel: UserRegisterRequest) -> AnyPublisher<Void, ErrorResponse> {
        networkService.request(api: UserAPI.register(requestModel))
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
}

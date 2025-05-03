//
//  UserRepository.swift
//  koin
//
//  Created by 김나훈 on 7/19/24.
//

import Combine

protocol UserRepository {
    func fetchUserData() -> AnyPublisher<UserDTO, ErrorResponse>
    func modify(requestModel: UserPutRequest) -> AnyPublisher<UserDTO, ErrorResponse>
    func register(requestModel: UserRegisterRequest) -> AnyPublisher<Void, ErrorResponse>
    func login(requestModel: LoginRequest) -> AnyPublisher<TokenDTO, ErrorResponse>
    func logout() -> AnyPublisher<String, Error>
    func findPassword(requestModel: FindPasswordRequest) -> AnyPublisher<Void, ErrorResponse>
    func checkDuplicatedPhoneNumber(requestModel: CheckDuplicatedPhoneNumberRequest) -> AnyPublisher<Void, ErrorResponse>
    func checkDuplicatedNickname(requestModel: CheckDuplicatedNicknameRequest) -> AnyPublisher<Void, ErrorResponse>
    func checkDuplicatedEmail(email: String) -> AnyPublisher<String, Error>
    func revoke() -> AnyPublisher<Void, ErrorResponse>
    func checkPassword(requestModel: CheckPasswordRequest) -> AnyPublisher<Void, ErrorResponse>
    func checkAuth() -> AnyPublisher<UserTypeResponse, ErrorResponse>
    func checkLogin() -> AnyPublisher<Bool, Never>
    func sendVerificationCode(requestModel: SendVerificationCodeRequest) -> AnyPublisher<SendVerificationCodeDTO, ErrorResponse>
    func checkVerificationCode(requestModel: CheckVerificationCodeRequest) -> AnyPublisher<Void, ErrorResponse>
    func checkDuplicatedId(requestModel: CheckDuplicatedIdRequest) -> AnyPublisher<Void, ErrorResponse>
}

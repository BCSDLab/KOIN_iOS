//
//  UserRepository.swift
//  koin
//
//  Created by 김나훈 on 7/19/24.
//

import Combine

protocol UserRepository {
    func fetchUserData() -> AnyPublisher<UserDto, ErrorResponse>
    func modify(requestModel: UserPutRequest) -> AnyPublisher<UserDto, ErrorResponse>
    func register(requestModel: UserRegisterRequest) -> AnyPublisher<Void, ErrorResponse>
    func login(requestModel: LoginRequest) -> AnyPublisher<TokenDto, ErrorResponse>
    func logout() -> AnyPublisher<String, Error>
    func findPassword(requestModel: FindPasswordRequest) -> AnyPublisher<Void, ErrorResponse>
    func checkDuplicatedPhoneNumber(requestModel: CheckDuplicatedPhoneNumberRequest) -> AnyPublisher<Void, ErrorResponse>
    func checkDuplicatedNickname(requestModel: CheckDuplicatedNicknameRequest) -> AnyPublisher<Void, ErrorResponse>
    func checkDuplicatedEmail(email: String) -> AnyPublisher<String, Error>
    func revoke() -> AnyPublisher<Void, ErrorResponse>
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

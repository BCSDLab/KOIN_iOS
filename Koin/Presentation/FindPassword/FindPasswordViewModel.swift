//
//  FindPasswordViewModel.swift
//  koin
//
//  Created by 김나훈 on 3/24/24.
//

import Combine
import Foundation

final class FindPasswordViewModel {
    
    // MARK: - Properties
    
    private var subscriptions: Set<AnyCancellable> = []
    private let userRepository = DefaultUserRepository(service: DefaultUserService())
    private lazy var findPasswordEmailUseCase = DefaultResetPasswordEmailUseCase(userRepository: userRepository)
    private lazy var findPasswordSmsUseCase = DefaultResetPasswordSmsUseCase(userRepository: userRepository)
    private lazy var sendVerificationCodeUseCase = DefaultSendVerificationCodeUseCase(userRepository: userRepository)
    private lazy var checkVerificationCodeUseCase = DefaultCheckVerificationCodeUsecase(userRepository: userRepository)
    private lazy var sendVerificationEmailUseCase = DefaultSendVerificationEmailUseCase(userRepository: userRepository)
    private lazy var checkVerificationEmailUseCase = DefaultCheckVerificationEmailUseCase(userRepository: userRepository)
    
    @Published var id: String = ""
    @Published var inputData: String = ""
    @Published var certNumber = ""
    
    @Published var password: String = "" {
        didSet {
            validatePassword()
            validatePasswordMatch()
        }
    }
    @Published var passwordMatch: String = "" {
        didSet {
            validatePasswordMatch()
        }
    }
    
    let sendMessagePublisher = PassthroughSubject<(String, Bool), Never>()
    let checkMessagePublisher = PassthroughSubject<(String, Bool), Never>()
    let changeSuccessPublisher = PassthroughSubject<Void, Never>()
    let toastMessagePublisher = PassthroughSubject<String, Never>()
    let passwordMessagePublisher = PassthroughSubject<(String, Bool), Never>()
    let passwordMatchMessagePublisher = PassthroughSubject<(String, Bool), Never>()
    @Published var isPasswordValidAll: Bool = false
}

extension FindPasswordViewModel {
    private func updatePasswordValidationState() {
        let passwordRegex = "^(?=.*[!@#$%^&*()_+=-])(?=.*[A-Za-z0-9])[A-Za-z0-9!@#$%^&*()_+=-]{6,18}$"
            let isPasswordValid = NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
            let isMatch = password == passwordMatch && !passwordMatch.isEmpty
            isPasswordValidAll = isPasswordValid && isMatch
        }
    private func validatePassword() {
        let passwordRegex = "^(?=.*[!@#$%^&*()_+=-])(?=.*[A-Za-z0-9])[A-Za-z0-9!@#$%^&*()_+=-]{6,18}$"
        let isValid = NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
        if isValid {
            passwordMessagePublisher.send(("사용 가능한 비밀번호입니다.", true))
        } else {
            passwordMessagePublisher.send(("특수문자 포함 영어와 숫자 6~18 자리로 입력해 주세요.", false))
        }
        updatePasswordValidationState()
    }
    
    private func validatePasswordMatch() {
        if passwordMatch.isEmpty {
            passwordMatchMessagePublisher.send(("비밀번호를 다시 입력해주세요.", false))
        } else if password == passwordMatch {
            passwordMatchMessagePublisher.send(("비밀번호가 일치합니다.", true))
        } else {
            passwordMatchMessagePublisher.send(("비밀번호가 일치하지 않습니다.", false))
        }
        updatePasswordValidationState()
    }
    func sendVerificationCode() {
        sendVerificationCodeUseCase.execute(request: .init(phoneNumber: inputData)).sink { [weak self] completion in
            if case let .failure(error) = completion {
                self?.sendMessagePublisher.send((error.message, false))
            }
        } receiveValue: { [weak self] _ in
            self?.sendMessagePublisher.send(("인증번호가 발송되었습니다.", true))
        }.store(in: &subscriptions)
    }
    
    func checkVerificationCode() {
        checkVerificationCodeUseCase.execute(phoneNumber: inputData, verificationCode: certNumber).sink { [weak self] completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
                self?.checkMessagePublisher.send((error.message, false))
            }
        } receiveValue: { [weak self] response in
            self?.checkMessagePublisher.send(("인증번호가 일치합니다.", true))
        }.store(in: &subscriptions)
    }
    
    func findPasswordSms(phoneNumber: String) {
        findPasswordSmsUseCase.execute(requestModel: .init(loginId: id, phoneNumber: inputData, newPassword: password)).sink { [weak self] completion in
            if case let .failure(error) = completion {
                self?.toastMessagePublisher.send(error.message)
            }
        } receiveValue: { [weak self] response in
            self?.changeSuccessPublisher.send()
        }.store(in: &subscriptions)
    }
    ///
    func sendVerificationEmail() {
        sendVerificationEmailUseCase.execute(requestModel: .init(email: inputData)).sink { [weak self] completion in
            if case let .failure(error) = completion {
                self?.sendMessagePublisher.send((error.message, false))
            }
        } receiveValue: { [weak self] response in
            self?.sendMessagePublisher.send(("인증번호가 발송되었습니다.", true))
        }.store(in: &subscriptions)
    }
    func checkVerificationEmail() {
        checkVerificationEmailUseCase.execute(requestModel: .init(email: inputData, verificationCode: certNumber)).sink { [weak self] completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
                self?.checkMessagePublisher.send((error.message, false))
            }
        } receiveValue: { [weak self] response in
            self?.checkMessagePublisher.send(("인증번호가 일치합니다.", true))
        }.store(in: &subscriptions)
    }
    func findPasswordEmail(email: String) {
        findPasswordEmailUseCase.execute(requestModel: .init(loginId: id, email: inputData, newPassword: password)).sink { [weak self] completion in
            if case let .failure(error) = completion {
                self?.toastMessagePublisher.send(error.message)
            }
        } receiveValue: { [weak self] response in
            self?.changeSuccessPublisher.send()
        }.store(in: &subscriptions)
    }
}

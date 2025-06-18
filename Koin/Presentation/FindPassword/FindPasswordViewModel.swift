//
//  FindPasswordViewModel.swift
//  koin
//
//  Created by 김나훈 on 3/24/24.
//

import Combine

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
    @Published var newPassword: String = ""
    
    let sendMessagePublisher = PassthroughSubject<(String, Bool), Never>()
    let checkMessagePublisher = PassthroughSubject<(String, Bool), Never>()
    let changeSuccessPublisher = PassthroughSubject<Void, Never>()
    let toastMessagePublisher = PassthroughSubject<String, Never>()
}

extension FindPasswordViewModel {
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
        findPasswordSmsUseCase.execute(requestModel: .init(loginId: id, phoneNumber: inputData, newPassword: newPassword)).sink { [weak self] completion in
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
        findPasswordEmailUseCase.execute(requestModel: .init(loginId: id, email: inputData, newPassword: newPassword)).sink { [weak self] completion in
            if case let .failure(error) = completion {
                self?.toastMessagePublisher.send(error.message)
            }
        } receiveValue: { [weak self] response in
            self?.changeSuccessPublisher.send()
        }.store(in: &subscriptions)
    }
}

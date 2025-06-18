//
//  FindIdViewModel.swift
//  koin
//
//  Created by 김나훈 on 6/17/25.
//

import Combine
import Foundation

final class FindIdViewModel {
    
    // MARK: - Properties
    private var subscriptions: Set<AnyCancellable> = []
    private let userRepository = DefaultUserRepository(service: DefaultUserService())
    private lazy var findIdSmsUseCase = DefaultFindIdSmsUseCase(userRepository: userRepository)
    private lazy var findIdEmailUseCase = DefaultFindIdEmailUseCase(userRepository: userRepository)
    private lazy var sendVerificationCodeUseCase = DefaultSendVerificationCodeUseCase(userRepository: userRepository)
    private lazy var checkVerificationCodeUseCase = DefaultCheckVerificationCodeUsecase(userRepository: userRepository)
    private lazy var sendVerificationEmailUseCase = DefaultSendVerificationEmailUseCase(userRepository: userRepository)
    private lazy var checkVerificationEmailUseCase = DefaultCheckVerificationEmailUseCase(userRepository: userRepository)
    private(set) var loginId: String?
    
    let sendMessagePublisher = PassthroughSubject<(String, Bool), Never>()
    let checkMessagePublisher = PassthroughSubject<(String, Bool), Never>()
}

extension FindIdViewModel {
    func sendVerificationCode(phoneNumber: String) {
        sendVerificationCodeUseCase.execute(request: .init(phoneNumber: phoneNumber)).sink { [weak self] completion in
            if case let .failure(error) = completion {
                self?.sendMessagePublisher.send((error.message, false))
            }
        } receiveValue: { [weak self] _ in
            self?.sendMessagePublisher.send(("인증번호가 발송되었습니다.", true))
        }.store(in: &subscriptions)
    }
    
    func checkVerificationCode(phoneNumber: String, code: String) {
        checkVerificationCodeUseCase.execute(phoneNumber: phoneNumber, verificationCode: code).sink { [weak self] completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
                self?.checkMessagePublisher.send((error.message, false))
            }
        } receiveValue: { [weak self] response in
            self?.findIdSms(phoneNumber: phoneNumber)
        }.store(in: &subscriptions)
    }
    
    func findIdSms(phoneNumber: String) {
        findIdSmsUseCase.execute(requestModel: .init(phoneNumber: phoneNumber)).sink { [weak self] completion in
            if case let .failure(error) = completion {
                self?.checkMessagePublisher.send((error.message, false))            }
        } receiveValue: { [weak self] response in
            self?.loginId = response.loginID
            self?.checkMessagePublisher.send(("인증번호가 일치합니다.", true))
        }.store(in: &subscriptions)
    }
    ///
    func sendVerificationEmail(email: String) {
        sendVerificationEmailUseCase.execute(requestModel: .init(email: email)).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            
        }.store(in: &subscriptions)
    }
    func checkVerificationEmail(email: String, code: String) {
        checkVerificationEmailUseCase.execute(requestModel: .init(email: email, verificationCode: code)).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            self?.findIdEmail(email: email)
        }.store(in: &subscriptions)
    }
    func findIdEmail(email: String) {
        findIdEmailUseCase.execute(requestModel: .init(email: email)).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            print(response)
        }.store(in: &subscriptions)
    }
}

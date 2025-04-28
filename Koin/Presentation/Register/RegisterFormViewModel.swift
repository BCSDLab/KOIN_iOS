//
//  RegisterFormViewModel.swift
//  koin
//
//  Created by 김나훈 on 4/10/25.
//

import Combine

final class RegisterFormViewModel: ViewModelProtocol {
    
    enum Input {
        case checkDuplicatedPhoneNumber(String)
        case sendVerificationCode(String)
    }
    
    enum Output {
        case showHttpResult(String, SceneColorAsset)
        case changeSendVerificationButtonStatus
        case sendVerificationCodeSuccess(response: SendVerificationCodeDTO)
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let checkDuplicatedPhoneNumberUseCase: CheckDuplicatedPhoneNumberUseCase
    private let sendVerificationCodeUseCase: SendVerificationCodeUsecase

    init(checkDuplicatedPhoneNumberUseCase: CheckDuplicatedPhoneNumberUseCase, sendVerificationCodeUseCase: SendVerificationCodeUsecase) {
        self.checkDuplicatedPhoneNumberUseCase = checkDuplicatedPhoneNumberUseCase
        self.sendVerificationCodeUseCase = sendVerificationCodeUseCase
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case let .checkDuplicatedPhoneNumber(phone):
                self?.checkDuplicatedPhoneNumber(phone: phone)
            case let .sendVerificationCode(phoneNumber):
                self?.sendVerificationCode(phoneNumber: phoneNumber)
            }
        }.store(in: &subscriptions)
        
        return outputSubject.eraseToAnyPublisher()
    }
}

extension RegisterFormViewModel {
    private func checkDuplicatedPhoneNumber(phone: String) {
        checkDuplicatedPhoneNumberUseCase.execute(phone: phone).sink { [weak self] completion in
            if case let .failure(error) = completion {
                if let code = Int(error.code) {
                    if code == 400 {
                        self?.outputSubject.send(.showHttpResult("올바른 전화번호 양식이 아닙니다. 다시 입력해 주세요.", .sub500))
                    } else if code == 409 {
                        self?.outputSubject.send(.showHttpResult("이미 존재하는 전화번호입니다.", .danger700))
                    }
                } else {
                    self?.outputSubject.send(.showHttpResult(error.message, .sub500))
                }
            }
        } receiveValue: { [weak self] (_: Void) in
            self?.outputSubject.send(.changeSendVerificationButtonStatus)
        }
        .store(in: &subscriptions)
    }
    
    private func sendVerificationCode(phoneNumber: String) {
        sendVerificationCodeUseCase.execute(request: SendVerificationCodeRequest(phoneNumber: phoneNumber))
            .sink { [weak self] completion in
                guard let self else { return }
                if case let .failure(error) = completion {
                    self.outputSubject.send(.showHttpResult(error.message, .sub500))
                }
            } receiveValue: { [weak self] response in
                print("✅ [ViewModel] 인증번호 발송 성공. 응답 데이터: \(response)")
                self?.outputSubject.send(.sendVerificationCodeSuccess(response: response))
            }
            .store(in: &subscriptions)
    }
}

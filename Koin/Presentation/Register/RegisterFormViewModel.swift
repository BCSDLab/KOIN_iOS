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
    }
    enum Output {
        case showHttpResult(String, SceneColorAsset)    // 400: 올바르지 않음, 409: 이미 있는 전화번호
        case changeSendVerificationButtonStatus
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let checkDuplicatedPhoneNumberUseCase: CheckDuplicatedPhoneNumberUseCase

    init(checkDuplicatedPhoneNumberUseCase: CheckDuplicatedPhoneNumberUseCase) {
        self.checkDuplicatedPhoneNumberUseCase = checkDuplicatedPhoneNumberUseCase
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case let .checkDuplicatedPhoneNumber(phone):
                self?.checkDuplicatedPhoneNumber(phone: phone)
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

}

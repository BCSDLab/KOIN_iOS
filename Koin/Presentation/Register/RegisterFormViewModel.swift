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
        case checkVerificationCode(String, String)
        case checkDuplicatedId(String)
        case getDeptList
        case checkDuplicatedNickname(String)
    }
    
    enum Output {
        case showHttpResult(String, SceneColorAsset)
        case changeSendVerificationButtonStatus
        case sendVerificationCodeSuccess(response: SendVerificationCodeDTO)
        case correctVerificationCode
        case successCheckDuplicatedId
        case showDeptDropDownList([String])
        case changeCheckButtonStatus
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let checkDuplicatedPhoneNumberUseCase: CheckDuplicatedPhoneNumberUseCase
    private let sendVerificationCodeUseCase: SendVerificationCodeUsecase
    private let checkVerificationCodeUseCase: CheckVerificationCodeUsecase
    private let checkDuplicatedIdUseCase: CheckDuplicatedIdUsecase
    private let fetchDeptListUseCase: FetchDeptListUseCase
    private let checkDuplicatedNicknameUseCase: CheckDuplicatedNicknameUseCase

    init(checkDuplicatedPhoneNumberUseCase: CheckDuplicatedPhoneNumberUseCase, sendVerificationCodeUseCase: SendVerificationCodeUsecase, checkVerificationCodeUseCase: CheckVerificationCodeUsecase, checkDuplicatedIdUseCase: CheckDuplicatedIdUsecase, fetchDeptListUseCase: FetchDeptListUseCase, checkDuplicatedNicknameUseCase: CheckDuplicatedNicknameUseCase) {
        self.checkDuplicatedPhoneNumberUseCase = checkDuplicatedPhoneNumberUseCase
        self.sendVerificationCodeUseCase = sendVerificationCodeUseCase
        self.checkVerificationCodeUseCase = checkVerificationCodeUseCase
        self.checkDuplicatedIdUseCase = checkDuplicatedIdUseCase
        self.fetchDeptListUseCase = fetchDeptListUseCase
        self.checkDuplicatedNicknameUseCase = checkDuplicatedNicknameUseCase
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case let .checkDuplicatedPhoneNumber(phone):
                self?.checkDuplicatedPhoneNumber(phone: phone)
            case let .sendVerificationCode(phoneNumber):
                self?.sendVerificationCode(phoneNumber: phoneNumber)
            case let .checkVerificationCode(phoneNumber, verificationCode):
                self?.checkVerificationCode(phoneNumber: phoneNumber, verificationCode: verificationCode)
            case let .checkDuplicatedId(loginId):
                self?.checkDuplicatedId(loginId: loginId)
            case .getDeptList:
                self?.fetchDeptList()
            case let .checkDuplicatedNickname(nickname):
                self?.checkDuplicatedNickname(nickname: nickname)
            }
        }.store(in: &subscriptions)
        
        return outputSubject.eraseToAnyPublisher()
    }
}

extension RegisterFormViewModel {
    private func checkDuplicatedPhoneNumber(phone: String) {
        checkDuplicatedPhoneNumberUseCase.execute(phone: phone).sink { [weak self] completion in
            if case let .failure(error) = completion {
                self?.outputSubject.send(.showHttpResult(error.message, .sub500))
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
                self?.outputSubject.send(.sendVerificationCodeSuccess(response: response))
            }
            .store(in: &subscriptions)
    }
    
    private func checkVerificationCode(phoneNumber: String, verificationCode: String) {
        checkVerificationCodeUseCase.execute(phoneNumber: phoneNumber, verificationCode: verificationCode).sink { [weak self] completion in
            if case let .failure(error) = completion {
                if let code = Int(error.code) {
                    if code == 400 {
                        self?.outputSubject.send(.showHttpResult(error.message, .sub500))
                    } else if code == 404 {
                        self?.outputSubject.send(.showHttpResult(error.message, .danger700))
                    }
                } else {
                    self?.outputSubject.send(.showHttpResult(error.message, .sub500))
                }
            }
        } receiveValue: { [weak self] (_: Void) in
            self?.outputSubject.send(.correctVerificationCode)
        }
        .store(in: &subscriptions)
    }
    
    private func checkDuplicatedId(loginId: String) {
        checkDuplicatedIdUseCase.execute(loginId: loginId).sink { [weak self] completion in
            if case let .failure(error) = completion {
                self?.outputSubject.send(.showHttpResult(error.message, .sub500))
            }
        } receiveValue: { [weak self] (_: Void) in
            self?.outputSubject.send(.successCheckDuplicatedId)
        }
        .store(in: &subscriptions)
    }

    private func fetchDeptList() {
        fetchDeptListUseCase.execute().sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.showDeptDropDownList(response))
        }.store(in: &subscriptions)
    }
    
    private func checkDuplicatedNickname(nickname: String) {
        checkDuplicatedNicknameUseCase.execute(nickname: nickname).sink { [weak self] completion in
            if case let .failure(error) = completion {
                self?.outputSubject.send(.showHttpResult(error.message, .danger700))
            }
        } receiveValue: { [weak self] _ in
            self?.outputSubject.send(.changeCheckButtonStatus)
        }.store(in: &subscriptions)
    }
}

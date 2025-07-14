//
//  LoginViewModel.swift
//  koin
//
//  Created by 김나훈 on 3/17/24.
//

import Combine
import Foundation

final class LoginViewModel: ViewModelProtocol {
    
    enum Input {
        case login(String, String)
        case logEvent(EventLabelType, EventParameter.EventCategory, Any)
    }
    enum Output {
        case showErrorMessage(String)
        case loginSuccess
        case showForceModal
        case showModifyModal
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let loginUseCase: LoginUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private let fetchUserDataUseCase =  DefaultFetchUserDataUseCase(userRepository: DefaultUserRepository(service: DefaultUserService()))
    
    init(loginUseCase: LoginUseCase, logAnalyticsEventUseCase: LogAnalyticsEventUseCase) {
        self.loginUseCase = loginUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case let .login(loginId, loginPw):
                self?.login(loginId: loginId, loginPw: loginPw)
            case let .logEvent(label, category, value):
                self?.makeLogAnalyticsEvent(label: label, category: category, value: value)
            }
        }.store(in: &subscriptions)
        
        return outputSubject.eraseToAnyPublisher()
    }
}

extension LoginViewModel {

    private func login(loginId: String, loginPw: String) {
        loginUseCase.execute(loginId: loginId, loginPw: loginPw).sink { [weak self] completion in
            if case .failure(let error) = completion {
                self?.outputSubject.send(.showErrorMessage(error.message))
            }
        } receiveValue: { [weak self] response in
            KeychainWorker.shared.create(key: .access, token: response.token)
            KeychainWorker.shared.create(key: .refresh, token: response.refreshToken)
            self?.makeLogAnalyticsEvent(label: EventParameter.EventLabel.User.login, category: .click, value: "로그인")
            self?.setUserInfo()
        }.store(in: &subscriptions)
    }
    private func setUserInfo() {
        fetchUserDataUseCase.execute().sink { [weak self] completion in
            if case .failure(let error) = completion {
                self?.outputSubject.send(.showErrorMessage(error.message))
            }
        } receiveValue: { [weak self] response in
            UserDataManager.shared.setUserData(userData: response)
            if response.userType == "STUDENT" {
                if response.name == nil ||
                    response.phoneNumber == nil ||
                    response.gender == nil ||
                    response.major == nil ||
                    response.studentNumber == nil {
                    
                    if !UserDefaults.standard.bool(forKey: "forceModal") {
                        self?.outputSubject.send(.showForceModal)
                        UserDefaults.standard.set(true, forKey: "forceModal")
                    } else {
                        self?.outputSubject.send(.showModifyModal)
                    }
                    
                } else {
                    self?.outputSubject.send(.loginSuccess)
                }
            } else {
                self?.outputSubject.send(.loginSuccess)
            }
        }.store(in: &subscriptions)

    }
    
    private func makeLogAnalyticsEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any) {
        logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
    }
}


//
//  LoginViewModel.swift
//  koin
//
//  Created by 김나훈 on 3/17/24.
//

import Combine

final class LoginViewModel: ViewModelProtocol {
    
    enum Input {
        case login(String, String)
        case logEvent(EventLabelType, EventParameter.EventCategory, Any)
    }
    enum Output {
        case showErrorMessage(String)
        case loginSuccess
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let loginUseCase: LoginUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    
    init(loginUseCase: LoginUseCase, logAnalyticsEventUseCase: LogAnalyticsEventUseCase) {
        self.loginUseCase = loginUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case let .login(email, password):
                self?.login(email: email, password: password)
            case let .logEvent(label, category, value):
                self?.makeLogAnalyticsEvent(label: label, category: category, value: value)
            }
        }.store(in: &subscriptions)
        
        return outputSubject.eraseToAnyPublisher()
    }
}

extension LoginViewModel {

    private func login(email: String, password: String) {
        loginUseCase.execute(email: email, password: password).sink { [weak self] completion in
            if case .failure(let error) = completion {
                self?.outputSubject.send(.showErrorMessage(error.message))
            }
        } receiveValue: { [weak self] response in
            KeyChainWorker.shared.create(key: .access, token: response.token)
            KeyChainWorker.shared.create(key: .refresh, token: response.refreshToken)
            self?.outputSubject.send(.loginSuccess)
            self?.makeLogAnalyticsEvent(label: EventParameter.EventLabel.User.login, category: .click, value: "로그인완료")
        }.store(in: &subscriptions)
    }
    
    private func makeLogAnalyticsEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any) {
        logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
    }
}


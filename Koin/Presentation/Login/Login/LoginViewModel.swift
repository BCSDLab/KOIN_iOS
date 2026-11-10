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
        case logEvent(EventLabelType, Any)
        case logSignUpEvent(EventLabelType, Any)
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
    private let fetchUserDataUseCase: FetchUserDataUseCase
    private let sendDeviceTokenIfNeededUseCase: SendDeviceTokenIfNeededUseCase
    
    init(
        loginUseCase: LoginUseCase,
        logAnalyticsEventUseCase: LogAnalyticsEventUseCase,
        fetchUserDataUseCase: FetchUserDataUseCase,
        sendDeviceTokenIfNeededUseCase: SendDeviceTokenIfNeededUseCase
    ) {
        self.loginUseCase = loginUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
        self.fetchUserDataUseCase = fetchUserDataUseCase
        self.sendDeviceTokenIfNeededUseCase = sendDeviceTokenIfNeededUseCase
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case let .login(loginId, loginPw):
                self?.login(loginId: loginId, loginPw: loginPw)
            case let .logEvent(label, value):
                self?.makeLogAnalyticsEvent(label: label, value: value)
            case let .logSignUpEvent(label, value):
                self?.makeSignUpLogEvent(label: label, value: value)
            }
        }.store(in: &subscriptions)
        
        return outputSubject.eraseToAnyPublisher()
    }
}

extension LoginViewModel {

    private func login(loginId: String, loginPw: String) {
        loginUseCase.execute(loginId: loginId, loginPw: loginPw).sink { [weak self] completion in
            if case .failure(let error) = completion {
                self?.makeLogAnalyticsEvent(label: EventParameter.EventLabel.Account.loginLoginConfirmClick, value: "로그인 실패")
                self?.outputSubject.send(.showErrorMessage(error.message))
            }
        } receiveValue: { [weak self] response in
            KeychainWorker.shared.create(key: .access, token: response.token)
            KeychainWorker.shared.create(key: .refresh, token: response.refreshToken)
            self?.makeLogAnalyticsEvent(label: EventParameter.EventLabel.Account.loginLoginConfirmClick, value: "로그인 완료")
            self?.setUserInfo()
            self?.sendDeviceTokenIfNeededUseCase.execute()
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
    
    private func makeLogAnalyticsEvent(label: EventLabelType, value: Any) {
        logAnalyticsEventUseCase.execute(label: label, value: value)
    }

    /// 회원가입 계약은 명세상 15분 유지되는 custom_session_id를 함께 보낸다.
    private func makeSignUpLogEvent(label: EventLabelType, value: Any) {
        let sessionId = CustomSessionManager.getOrCreateSessionId(duration: .fifteenMinutes, eventName: "sign_up", loginStatus: 0, platform: "iOS")
        logAnalyticsEventUseCase.execute(label: label, value: value, parameters: ["custom_session_id": sessionId])
    }

}


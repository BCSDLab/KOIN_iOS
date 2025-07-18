//
//  SettingsViewModel.swift
//  koin
//
//  Created by 김나훈 on 9/19/24.
//

import Combine

final class SettingsViewModel: ViewModelProtocol {
    
    // MARK: - Input
    
    enum Input {
        case checkLogin(MovingScene)
        case logEvent(EventLabelType, EventParameter.EventCategory, Any)
    }
    
    // MARK: - Output
    enum Output {
        case showToast(String, Bool, MovingScene, UserType?)
    }
    
    enum MovingScene {
        case profile
        case changePassword
        case noti
    }
    
    // MARK: - Properties
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let checkAuthUseCase = DefaultCheckAuthUseCase(userRepository: DefaultUserRepository(service: DefaultUserService()))
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    
    // MARK: - Initialization
    
    init(logAnalyticsEventUseCase: LogAnalyticsEventUseCase) {
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case let .checkLogin(scene):
                self?.checkLogin(movingScene: scene)
            case let .logEvent(label, category, value):
                self?.makeLogAnalyticsEvent(label: label, category: category, value: value)
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension SettingsViewModel {
    private func checkLogin(movingScene: MovingScene) {
        checkAuthUseCase.execute().sink { [weak self] completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
                self?.outputSubject.send(.showToast(error.message, false, movingScene, nil))
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.showToast("", true, movingScene, response.userType))
        }.store(in: &subscriptions)
    }
    
    private func makeLogAnalyticsEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any) {
        logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
    }
}

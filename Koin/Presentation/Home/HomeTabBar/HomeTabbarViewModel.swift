//
//  HomeTabBarViewModel.swift
//  koin
//
//  Created by 홍기정 on 6/7/26.
//

import Combine

final class HomeTabBarViewModel: ViewModelProtocol {
    enum Input {
        case logEvent(EventLabelType, Any)
        case checkNotification
    }
    
    enum Output {
        case hasUnreadNotifications(Bool)
    }

    // MARK: - Properties
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private let checkHasUnreadNotificationHistoryUseCase: CheckHasUnreadNotificationHistoryUseCase
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []

    // MARK: - Initializer
    init(
        logAnalyticsEventUseCase: LogAnalyticsEventUseCase,
        checkHasUnreadNotificationHistoryUseCase: CheckHasUnreadNotificationHistoryUseCase
    ) {
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
        self.checkHasUnreadNotificationHistoryUseCase = checkHasUnreadNotificationHistoryUseCase
    }

    // MARK: - Transform
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case let .logEvent(label, value):
                self?.makeLogAnalyticsEvent(label: label, value: value)
            case .checkNotification:
                self?.checkUnreadNotifications()
            }
        }.store(in: &subscriptions)
        
        return outputSubject.eraseToAnyPublisher()
    }
}

extension HomeTabBarViewModel {
    
    private func makeLogAnalyticsEvent(
        label: EventLabelType,
        value: Any
    ) {
        logAnalyticsEventUseCase.execute(label: label, value: value)
    }
    
    private func checkUnreadNotifications() {
        Task {
            do {
                let hasUnreadNotifications = try await checkHasUnreadNotificationHistoryUseCase.execute()
                outputSubject.send(.hasUnreadNotifications(hasUnreadNotifications))
            } catch {
                print(#function, "failed")
                print(error)
            }
        }
    }
}

//
//  HomeTabBarViewModel.swift
//  koin
//
//  Created by 홍기정 on 6/7/26.
//

import Combine

final class HomeTabBarViewModel: ViewModelProtocol {
    enum Input {
        case logEvent(EventLabelType, EventParameter.EventCategory, Any)
        case checkNotification
    }
    
    enum Output {
        case hasUnreadNotifications(Bool)
    }

    // MARK: - Properties
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private let fetchNotificationHistoryUseCase: FetchNotificationHistoryUseCase
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []

    // MARK: - Initializer
    init(
        logAnalyticsEventUseCase: LogAnalyticsEventUseCase,
        fetchNotificationHistoryUseCase: FetchNotificationHistoryUseCase
    ) {
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
        self.fetchNotificationHistoryUseCase = fetchNotificationHistoryUseCase
    }

    // MARK: - Transform
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case let .logEvent(label, category, value):
                self?.makeLogAnalyticsEvent(label: label, category: category, value: value)
            case .checkNotification:
                self?.checkNotification()
            }
        }.store(in: &subscriptions)
        
        return outputSubject.eraseToAnyPublisher()
    }
}

extension HomeTabBarViewModel {
    
    private func makeLogAnalyticsEvent(
        label: EventLabelType,
        category: EventParameter.EventCategory,
        value: Any
    ) {
        logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
    }
    
    private func checkNotification() {
        Task {
            let notifications = try? await fetchNotificationHistoryUseCase.execute()
            let unreadNotifications = notifications?.filter { !$0.isRead }
            outputSubject.send(.hasUnreadNotifications(unreadNotifications?.isEmpty == false))
        }
    }
}

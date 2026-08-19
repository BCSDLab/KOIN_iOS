//
//  NotificationViewModel.swift
//  koin
//
//  Created by 홍기정 on 6/3/26.
//

import Combine
import Foundation

final class NotificationViewModel: ViewModelProtocol {
    
    enum Input {
        case viewDidLoad
        case reload
        case selectNotification(id: String)
        case deleteNotification(id: String)
        case deleteAllNotifications
        case markAllAsRead
        case logEvent(EventLabelType, EventParameter.EventCategory, Any)
    }
    
    enum Output {
        case updateNotifications([NotificationHistoryItem])
        case selectedNotification(NotificationHistoryItem)
        case showToast(String)
    }
    
    // MARK: - Properties
    
    private let fetchNotificationHistoryUseCase: FetchNotificationHistoryUseCase
    private let deleteNotificationHistoryUseCase: DeleteNotificationHistoryUseCase
    private let updateNotificationHistoryUseCase: UpdateNotificationHistoryUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var notificationHistoryItems: [NotificationHistoryItem] = []
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Initializer
    init(
        fetchNotificationHistoryUseCase: FetchNotificationHistoryUseCase,
        deleteNotificationHistoryUseCase: DeleteNotificationHistoryUseCase,
        updateNotificationHistoryUseCase: UpdateNotificationHistoryUseCase,
        logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    ) {
        self.fetchNotificationHistoryUseCase = fetchNotificationHistoryUseCase
        self.deleteNotificationHistoryUseCase = deleteNotificationHistoryUseCase
        self.updateNotificationHistoryUseCase = updateNotificationHistoryUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
    }
    
    // MARK: - Transform
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .receive(on: DispatchQueue.main)
            .sink { [weak self] input in
            switch input {
            case .viewDidLoad, .reload:
                self?.loadNotifications()
            case .selectNotification(let id):
                self?.selectNotification(id: id)
            case .deleteNotification(let id):
                self?.deleteNotification(id: id)
            case .deleteAllNotifications:
                self?.deleteAllNotifications()
            case .markAllAsRead:
                self?.markAllAsRead()
            case let .logEvent(label, category, value):
                self?.makeLogAnalyticsEvent(label: label, category: category, value: value)
            }
        }
        .store(in: &subscriptions)
        
        return outputSubject.eraseToAnyPublisher()
    }
}

// MARK: - Private

private extension NotificationViewModel {
    
    private func loadNotifications() {
        Task {
            do {
                let notifications = try await fetchNotificationHistoryUseCase.execute()
                self.notificationHistoryItems = notifications
                outputSubject.send(.updateNotifications(notifications))
            } catch {
                outputSubject.send(.showToast(error.localizedDescription))
            }
        }
    }

    private func selectNotification(id: String) {
        guard let notification = notificationHistoryItems.first(where: { $0.id == id }),
              let logValue = notification.logValue else {
            return
        }
        markAsRead(id: id)
        
        outputSubject.send(.selectedNotification(notification))
        
        makeLogAnalyticsEvent(
            label: EventParameter.EventLabel.Campus.notificationList,
            category: .click,
            value: logValue
        )
    }

    private func deleteNotification(id: String) {
        notificationHistoryItems.removeAll { $0.id == id }
        Task {
            do {
                try await deleteNotificationHistoryUseCase.delete(id: id)
            } catch {
                outputSubject.send(.showToast(error.localizedDescription))
            }
        }
    }
    
    private func deleteAllNotifications() {
        notificationHistoryItems.removeAll()
        Task {
            do {
                try await deleteNotificationHistoryUseCase.deleteAll()
            } catch {
                outputSubject.send(.showToast(error.localizedDescription))
            }
        }
    }
    
    private func markAsRead(id: String) {
        if let index = notificationHistoryItems.firstIndex(where: { $0.id == id }) {
            notificationHistoryItems[index].isRead = true
        }
        
        Task {
            try? await updateNotificationHistoryUseCase.markAsRead(id: id)
        }
    }
    
    private func markAllAsRead() {
        for index in notificationHistoryItems.indices {
            notificationHistoryItems[index].isRead = true
        }
        Task {
            do {
                try await updateNotificationHistoryUseCase.markAllAsRead()
            } catch {
                outputSubject.send(.showToast(error.localizedDescription))
            }
        }
    }
    
    private func makeLogAnalyticsEvent(
        label: EventLabelType,
        category: EventParameter.EventCategory,
        value: Any
    ) {
        logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
    }
}

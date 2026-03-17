//
//  CallVanNotificationViewModel.swift
//  koin
//
//  Created by 홍기정 on 3/5/26.
//

import Foundation
import Combine

final class CallVanNotificationViewModel: ViewModelProtocol {
    
    enum Input {
        case viewWillAppear
        case refresh
        case setNotificationRead(Int)
        case setAllNotificationsRead
        case deleteNotification(Int)
        case deleteAllNotifications
    }
    
    enum Output {
        case updateNotifications([CallVanNotification])
        case showToast(String)
    }
    
    // MARK: - Properties
    private let fetchCallVanNotificationListUseCase: FetchCallVanNotificationListUseCase
    private let postNotificationReadUseCase: PostNotificationReadUseCase
    private let postAllNotificationsReadUseCase: PostAllNotificationsReadUseCase
    private let deleteAllNotificationsUseCase: DeleteAllNotificationsUseCase
    private let deleteNotificationUseCase: DeleteNotificationUseCase
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - Initializer
    init(fetchCallVanNotificationListUseCase: FetchCallVanNotificationListUseCase,
         postNotificationReadUseCase: PostNotificationReadUseCase,
         postAllNotificationsReadUseCase: PostAllNotificationsReadUseCase,
         deleteNotificationUseCase: DeleteNotificationUseCase,
         deleteAllNotificationsUseCase: DeleteAllNotificationsUseCase) {
        self.fetchCallVanNotificationListUseCase = fetchCallVanNotificationListUseCase
        self.postNotificationReadUseCase = postNotificationReadUseCase
        self.postAllNotificationsReadUseCase = postAllNotificationsReadUseCase
        self.deleteNotificationUseCase = deleteNotificationUseCase
        self.deleteAllNotificationsUseCase = deleteAllNotificationsUseCase
    }
    
    // MARK: - Transform
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            guard let self else { return }
            switch input {
            case .viewWillAppear:
                updateNotifications()
            case .setNotificationRead(let notificationId):
                setNotificationRead(notificationId)
            case .setAllNotificationsRead:
                setAllNotificationsRead()
            case .deleteNotification(let notificationId):
                deleteNotification(notificationId)
            case .deleteAllNotifications:
                deleteAllNotifications()
            case .refresh:
                refresh()
            }
        }.store(in: &subscriptions)
        
        return outputSubject.eraseToAnyPublisher()
    }
}

extension CallVanNotificationViewModel {
    
    private func refresh() {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) { [weak self] in
            self?.updateNotifications()
        }
    }
    
    private func updateNotifications() {
        fetchCallVanNotificationListUseCase.execute().sink(
            receiveCompletion: { [weak self] comepltion in
                if case .failure(let error) = comepltion {
                    self?.outputSubject.send(.showToast(error.message))
                }
            },
            receiveValue: { [weak self] notifications in
                guard let self else { return }
                outputSubject.send(.updateNotifications(notifications))
            }
        ).store(in: &subscriptions)
    }
    
    private func setNotificationRead(_ notificationId: Int) {
        postNotificationReadUseCase.execute(notificationId: notificationId).sink(
            receiveCompletion: { [weak self] comepltion in
                if case .failure(let error) = comepltion {
                    self?.outputSubject.send(.showToast(error.message))
                }
            },
            receiveValue: { _ in }
        ).store(in: &subscriptions)
    }
    
    private func setAllNotificationsRead() {
        postAllNotificationsReadUseCase.execute().sink(
            receiveCompletion: { [weak self] comepltion in
                if case .failure(let error) = comepltion {
                    self?.outputSubject.send(.showToast(error.message))
                }
            },
            receiveValue: { _ in }
        ).store(in: &subscriptions)
    }
    
    private func deleteNotification(_ notificationId: Int) {
        deleteNotificationUseCase.execute(notificationId: notificationId).sink(
            receiveCompletion: { [weak self] comepltion in
                if case .failure(let error) = comepltion {
                    self?.outputSubject.send(.showToast(error.message))
                }
            },
            receiveValue: { _ in }
        ).store(in: &subscriptions)
    }
    
    private func deleteAllNotifications() {
        deleteAllNotificationsUseCase.execute().sink(
            receiveCompletion: { [weak self] comepltion in
                if case .failure(let error) = comepltion {
                    self?.outputSubject.send(.showToast(error.message))
                }
            },
            receiveValue: { _ in }
        ).store(in: &subscriptions)
    }
}

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
        case deleteNotification(id: Int)
    }
    
    enum Output {
        case updateNotifications([NotificationItem])
        case updateLoading(Bool)
        case showToast(String)
    }
    
    // MARK: - Properties
    
    private let fetchNotificationListUseCase: FetchNotificationListUseCase
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Initializer
    init(fetchNotificationListUseCase: FetchNotificationListUseCase) {
        self.fetchNotificationListUseCase = fetchNotificationListUseCase
    }
    
    // MARK: - Transform
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case .viewDidLoad, .reload:
                self?.loadNotifications()
            case .deleteNotification(let id):
                self?.deleteNotification(id: id)
            }
        }
        .store(in: &subscriptions)
        
        return outputSubject.eraseToAnyPublisher()
    }
}

// MARK: - Private

private extension NotificationViewModel {
    
    private func loadNotifications() {
        outputSubject.send(.updateLoading(true))
        fetchNotificationListUseCase.execute().sink(
                receiveCompletion: { [weak self] completion in
                    self?.outputSubject.send(.updateLoading(false))
                    if case .failure(let error) = completion {
                        self?.outputSubject.send(.showToast(error.message))
                    }
                },
                receiveValue: { [weak self] notifications in
                    guard let self else { return }
                    self.outputSubject.send(.updateNotifications(notifications))
                    self.outputSubject.send(.updateLoading(false))
                }
            )
            .store(in: &subscriptions)
    }

    private func deleteNotification(id: Int) {
        // TODO: API 연결 시 성공/실패와 관계없이 화면 상태는 되돌리지 않는다.
    }
}

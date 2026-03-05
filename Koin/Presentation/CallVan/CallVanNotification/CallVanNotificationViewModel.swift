//
//  CallVanNotificationViewModel.swift
//  koin
//
//  Created by 홍기정 on 3/5/26.
//

import Foundation
import Combine

final class CallVanNotificationViewModel {
    
    enum Input {
        case viewDidLoad
    }
    
    enum Output {
        case updateNotifications([CallVanNotification])
    }
    
    // MARK: - Properties
    private let fetchCallVanNotificationListUseCase: FetchCallVanNotificationListUseCase
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - Initializer
    init(fetchCallVanNotificationListUseCase: FetchCallVanNotificationListUseCase) {
        self.fetchCallVanNotificationListUseCase = fetchCallVanNotificationListUseCase
    }
    
    // MARK: - Transform
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            guard let self else { return }
            switch input {
            case .viewDidLoad:
                updateNotifications()
            }
        }.store(in: &subscriptions)
        
        return outputSubject.eraseToAnyPublisher()
    }
    
    private func updateNotifications() {
        fetchCallVanNotificationListUseCase.execute().sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] notifications in
                guard let self else { return }
                outputSubject.send(.updateNotifications(notifications))
            }
        ).store(in: &subscriptions)
    }
}

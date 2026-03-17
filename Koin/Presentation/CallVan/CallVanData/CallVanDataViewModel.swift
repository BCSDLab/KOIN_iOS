//
//  CallVanDataViewModel.swift
//  koin
//
//  Created by 홍기정 on 3/10/26.
//

import Foundation
import Combine

final class CallVanDataViewModel: ViewModelProtocol {
    
    enum Output {
        case update(CallVanData)
        case updateBell(alert: Bool)
    }
    enum Input {
        case viewWillAppear
        case refresh
    }
    
    // MARK: - Properties
    let postId: Int
    private let fetchCallVanDataUseCase: FetchCallVanDataUseCase
    private let fetchCallVanNotificationListUseCase: FetchCallVanNotificationListUseCase
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - Initializer
    init(
        postId: Int,
        fetchCallVanDataUseCase: FetchCallVanDataUseCase,
        fetchCallVanNotificationListUseCase: FetchCallVanNotificationListUseCase
    ) {
        self.postId = postId
        self.fetchCallVanDataUseCase = fetchCallVanDataUseCase
        self.fetchCallVanNotificationListUseCase = fetchCallVanNotificationListUseCase
    }
    
    // MARK: - Public
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            guard let self else { return }
            switch input {
            case .viewWillAppear:
                fetchData()
                fetchNotification()
            case .refresh:
                refresh()
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension CallVanDataViewModel {
    
    private func refresh() {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) { [weak self] in
            self?.fetchData()
            self?.fetchNotification()
        }
    }
    
    private func fetchData() {
        fetchCallVanDataUseCase.execute(postId: postId).sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] callVanData in
                self?.outputSubject.send(.update(callVanData))
            }
        ).store(in: &subscriptions)
    }
    
    private func fetchNotification() {
        fetchCallVanNotificationListUseCase.execute().sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] notifications in
                let alert = notifications.filter { !$0.isRead }.count != 0
                self?.outputSubject.send(.updateBell(alert: alert))
            }
        ).store(in: &subscriptions)
    }
}

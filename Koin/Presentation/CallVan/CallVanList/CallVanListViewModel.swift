//
//  CallVanListViewModel.swift
//  koin
//
//  Created by 홍기정 on 3/5/26.
//

import Foundation
import Combine

final class CallVanListViewModel {
    
    enum Input {
        case viewDidLoad
        case checkLoginToParticapate
    }
    enum Output {
        case updateNotification([CallVanListPost])
        case didCheckLoginToParticapate(Bool)
    }
    
    // MARK: - Properties
    private let checkLoginUseCase: CheckLoginUseCase
    private let fetchCallVanListUseCase: FetchCallVanListUseCase
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private var filterState = CallVanListRequest()
    
    // MARK: - Intializer
    init(checkLoginUseCase: CheckLoginUseCase,
         fetchCallVanListUseCase: FetchCallVanListUseCase) {
        self.checkLoginUseCase = checkLoginUseCase
        self.fetchCallVanListUseCase = fetchCallVanListUseCase
    }
    
    // MARK: - Transform
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            guard let self else { return }
            switch input {
            case .checkLoginToParticapate:
                checkLoginToParticapate()
            case .viewDidLoad:
                updateNotification()
            }
        }.store(in: &subscriptions)
        
        return outputSubject.eraseToAnyPublisher()
    }
}

extension CallVanListViewModel {
    
    private func checkLoginToParticapate() {
        checkLoginUseCase.execute().sink(receiveValue: { [weak self] isLoggedIn in
            guard let self else { return }
            outputSubject.send(.didCheckLoginToParticapate(isLoggedIn))
        }).store(in: &subscriptions)
    }
    
    private func updateNotification() {
        fetchCallVanListUseCase.execute(request: filterState).sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] callVanList in
                guard let self else { return }
                outputSubject.send(.updateNotification(callVanList.posts))
            }
        ).store(in: &subscriptions)
    }
}

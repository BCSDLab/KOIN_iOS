//
//  LostItemDataViewModel.swift
//  koin
//
//  Created by 홍기정 on 1/19/26.
//

import Foundation
import Combine

final class LostItemDataViewModel {
    
    enum Input {
        case checkLogIn
    }
    enum Output {
        case navigateToChat
        case showLoginModal
    }
    
    // MARK: - Properties
    private let checkLoginUseCase: CheckLoginUseCase
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - Initializer
    init(checkLoginUseCase: CheckLoginUseCase) {
        self.checkLoginUseCase = checkLoginUseCase
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            guard let self else { return }
            switch input {
            case .checkLogIn:
                self.checkLogin()
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension LostItemDataViewModel {
    
    private func checkLogin() {
        checkLoginUseCase.execute().sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] isLoggedIn in
                guard let self else { return }
                if isLoggedIn {
                    outputSubject.send(.navigateToChat)
                } else {
                    outputSubject.send(.showLoginModal)
                }
            }
        ).store(in: &subscriptions)
    }
}

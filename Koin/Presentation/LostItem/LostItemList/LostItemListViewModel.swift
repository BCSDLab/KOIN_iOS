//
//  LostItemListViewModel.swift
//  koin
//
//  Created by 홍기정 on 1/17/26.
//

import Foundation
import Combine

final class LostItemListViewModel {
    
    enum Input {
        case checkLogin
    }
    enum Output {
        case presentPostType
        case showLogin
    }
    
    // MARK: - Properties
    private let checkLoginUseCase: CheckLoginUseCase
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscription: Set<AnyCancellable> = []
    var filterState = FetchLostItemRequest()
    
    
    // MARK: - Initializer
    init(checkLoginUseCase: CheckLoginUseCase) {
        self.checkLoginUseCase = checkLoginUseCase
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            guard let self else { return }
            switch input {
            case .checkLogin:
                self.checkLogin()
            }
        }.store(in: &subscription)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension LostItemListViewModel {
    
    private func checkLogin() {
        checkLoginUseCase.execute().sink(
            receiveCompletion: { _ in},
            receiveValue: { [weak self] loggedIn in
                if loggedIn {
                    self?.outputSubject.send(.presentPostType)
                } else {
                    self?.outputSubject.send(.showLogin)
                }
            }
        ).store(in: &subscription)
    }
}

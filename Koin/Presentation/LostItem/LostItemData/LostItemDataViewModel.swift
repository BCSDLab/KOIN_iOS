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
        case viewDidLoad
        case checkLogIn
    }
    enum Output {
        case updateData(LostItemData)
        case navigateToChat
        case showLoginModal
    }
    
    // MARK: - Properties
    private let checkLoginUseCase: CheckLoginUseCase
    private let fetchLostItemDataUseCase: FetchLostItemDataUseCase
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let id: Int
    
    // MARK: - Initializer
    init(checkLoginUseCase: CheckLoginUseCase,
         fetchLostItemDataUseCase: FetchLostItemDataUseCase,
         id: Int) {
        self.checkLoginUseCase = checkLoginUseCase
        self.fetchLostItemDataUseCase = fetchLostItemDataUseCase
        self.id = id
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            guard let self else { return }
            switch input {
            case .viewDidLoad:
                self.loadData()
                //self.loadList()
            case .checkLogIn:
                self.checkLogin()
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension LostItemDataViewModel {
    
    private func loadData() {
        fetchLostItemDataUseCase.execute(id: id).sink(
            receiveCompletion: { completion in
                if case .failure(let failure) = completion {
                    print(failure)
                }
            },
            receiveValue: { [weak self] lostItemData in
                self?.outputSubject.send(.updateData(lostItemData))
            }
        ).store(in: &subscriptions)
    }
    
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

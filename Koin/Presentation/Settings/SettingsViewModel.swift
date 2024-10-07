//
//  SettingsViewModel.swift
//  koin
//
//  Created by 김나훈 on 9/19/24.
//

import Combine

final class SettingsViewModel: ViewModelProtocol {
    
    // MARK: - Input
    
    enum Input {
        case checkLogin(MovingScene)
    }
    // MARK: - Output
    enum Output {
        case showToast(String, Bool, MovingScene)
    }
    
    enum MovingScene {
        case profile
        case changePassword
        case noti
    }
    
    // MARK: - Properties
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let fetchUserDataUseCase: FetchUserDataUseCase
    
    // MARK: - Initialization
    
    init(fetchUserDataUseCase: FetchUserDataUseCase) {
        self.fetchUserDataUseCase = fetchUserDataUseCase
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case let .checkLogin(scene):
                self?.checkLogin(movingScene: scene)
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension SettingsViewModel {
    private func checkLogin(movingScene: MovingScene) {
        fetchUserDataUseCase.execute().sink { [weak self] completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
                self?.outputSubject.send(.showToast(error.message, false, movingScene))
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.showToast("", true, movingScene))
        }.store(in: &subscriptions)
    }
    
}

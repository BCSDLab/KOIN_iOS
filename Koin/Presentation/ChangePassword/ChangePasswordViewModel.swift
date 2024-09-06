//
//  ChangePasswordViewModel.swift
//  koin
//
//  Created by 김나훈 on 9/5/24.
//

import Combine

final class ChangePasswordViewModel: ViewModelProtocol {
    
    // MARK: - Input
    
    enum Input {
        case fetchUserData
        case checkPassword(String)
    }
    
    // MARK: - Output
    
    enum Output {
        case showToast(String, Bool)
        case showEmail(String)
        case passNextStep
    }
    
    // MARK: - Properties
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let fetchUserDataUseCase: FetchUserDataUseCase
    private let checkPasswordUseCase: CheckPasswordUseCase
    private let modifyUseCase: ModifyUseCase
    private (set)var currentStep: Int = 1
    
    // MARK: - Initialization
    
    init(fetchUserDataUseCase: FetchUserDataUseCase, checkPasswordUseCase: CheckPasswordUseCase, modifyUseCase: ModifyUseCase) {
        self.fetchUserDataUseCase = fetchUserDataUseCase
        self.checkPasswordUseCase = checkPasswordUseCase
        self.modifyUseCase = modifyUseCase
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case .fetchUserData:
                self?.fetchUserData()
            case let .checkPassword(password):
                self?.checkPassword(password: password)
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
    
}

extension ChangePasswordViewModel {
    private func fetchUserData() {
        fetchUserDataUseCase.execute().sink { [weak self] completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
                self?.outputSubject.send(.showToast(error.message, false))
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.showEmail(response.email ?? ""))
        }.store(in: &subscriptions)
    }
    
    private func checkPassword(password: String) {
        checkPasswordUseCase.execute(password: password).sink { [weak self] completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
                self?.outputSubject.send(.showToast(error.message, false))
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.passNextStep)
        }.store(in: &subscriptions)
    }
    
}

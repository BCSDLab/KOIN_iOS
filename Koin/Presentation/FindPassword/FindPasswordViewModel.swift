//
//  FindPasswordViewModel.swift
//  koin
//
//  Created by 김나훈 on 3/24/24.
//

import Combine

final class FindPasswordViewModel: ViewModelProtocol {
    
    // MARK: - Input
    
    enum Input {
        case findPassword(String)
    }
    
    // MARK: - Output
    
    enum Output {
        case showHttpErrorMessage(String)
        case sendEmailSuccess
    }
    
    // MARK: - Properties
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let findPasswordUseCase: FindPasswordUseCase
    
    // MARK: - Initialization
    
    init(findPasswordUseCase: FindPasswordUseCase) {
        self.findPasswordUseCase = findPasswordUseCase
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case let .findPassword(email):
                self?.findPassword(email)
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
    
}

extension FindPasswordViewModel {
   
    private func findPassword(_ email: String) {
        findPasswordUseCase.execute(email: email).sink { [weak self] completion in
            if case let .failure(error) = completion {
                self?.outputSubject.send(.showHttpErrorMessage(error.message))
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.sendEmailSuccess)
        }.store(in: &subscriptions)
    }

}

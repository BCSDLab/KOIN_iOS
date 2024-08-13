//
//  ReviewListViewModel.swift
//  koin
//
//  Created by 김나훈 on 8/13/24.
//

import Combine

final class ReviewListViewModel: ViewModelProtocol {
        
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let fetchUserDataUseCase: FetchUserDataUseCase = DefaultFetchUserDataUseCase(userRepository: DefaultUserRepository(service: DefaultUserService()))
    var shopId: Int = 0
    var deleteParameter: (Int, Int) = (0, 0)

    
    enum Input {
       case checkLogin
    }
    enum Output {
        case updateLoginStatus(Bool)
    }
 
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case .checkLogin:
                self?.checkLogin()
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension ReviewListViewModel {
    
    private func checkLogin() {
        fetchUserDataUseCase.execute().sink { [weak self] completion in
            if case .failure = completion {
                self?.outputSubject.send(.updateLoginStatus(false))
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.updateLoginStatus(true))
        }.store(in: &subscriptions)
    }
   
}

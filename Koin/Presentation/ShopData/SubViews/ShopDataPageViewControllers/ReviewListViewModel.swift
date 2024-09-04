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
       case checkLogin((Int, Int)?)
    }
    enum Output {
        case updateLoginStatus(Bool, (Int, Int)?)
    }
 
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case let .checkLogin(parameter):
                self?.checkLogin(parameter: parameter)
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension ReviewListViewModel {
    
    private func checkLogin(parameter: (Int, Int)?) {
        fetchUserDataUseCase.execute().sink { [weak self] completion in
            if case .failure = completion {
                self?.outputSubject.send(.updateLoginStatus(false, parameter))
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.updateLoginStatus(true, parameter))
        }.store(in: &subscriptions)
    }
   
}

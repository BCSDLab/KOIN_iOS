//
//  MyProfileViewModel.swift
//  koin
//
//  Created by 김나훈 on 9/5/24.
//

import Combine

final class MyProfileViewModel: ViewModelProtocol {
    
    // MARK: - Input
    
    enum Input {
        case fetchUserData
        case revoke
    }
    
    // MARK: - Output
    
    enum Output {
      
    }
    
    // MARK: - Properties
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let fetchUserDataUseCase: FetchUserDataUseCase
    private let revokeUseCase: RevokeUseCase
    
    // MARK: - Initialization
    
    init(fetchUserDataUseCase: FetchUserDataUseCase, revokeUseCase: RevokeUseCase) {
        self.fetchUserDataUseCase = fetchUserDataUseCase
        self.revokeUseCase = revokeUseCase
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case .fetchUserData:
                print(1)
            case .revoke:
                print(2)
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
    
}

extension MyProfileViewModel {
    private func fetchUserData() {
        fetchUserDataUseCase.execute().sink { [weak self] completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
              //  self?.outputSubject.send(.loginAgain)
            }
        } receiveValue: { [weak self] response in
          ///  self?.userNickname = response.nickname
         //   self?.outputSubject.send(.showUserProfile(response))
        }.store(in: &subscriptions)
    }
    
    private func revoke() {
        revokeUseCase.execute().sink { [weak self] completion in
            if case let .failure(error) = completion {
                switch error.code {
                case "401" : self?.outputSubject.send(.loginAgain)
                default: self?.outputSubject.send(.showHttpResult(error.message, .danger700))
                }
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.revokeSuccess)
        }.store(in: &subscriptions)
    }
    
}

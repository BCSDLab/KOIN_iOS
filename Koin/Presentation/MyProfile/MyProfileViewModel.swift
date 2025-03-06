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
        case showToast(String, Bool)
        case showProfile(UserDTO)
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
                self?.fetchUserData()
            case .revoke:
                self?.revoke()
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
                self?.outputSubject.send(.showToast(error.message, false))
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.showProfile(response))
        }.store(in: &subscriptions)
    }
    
    private func revoke() {
        revokeUseCase.execute().sink { [weak self] completion in
            if case let .failure(error) = completion {
                self?.outputSubject.send(.showToast(error.message, false))
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.showToast("회원탈퇴가 완료되었습니다.", true))
            UserDataManager.shared.resetUserData()
        }.store(in: &subscriptions)
    }
    
}

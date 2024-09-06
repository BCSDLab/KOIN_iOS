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
        case changePassword(String)
    }
    
    // MARK: - Output
    
    enum Output {
        case showToast(String, Bool, Bool)
        case showErrorMessage(String)
        case showEmail(String)
        case passNextStep
        case updateButtonEnable(Bool)
    }
    
    // MARK: - Properties
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let fetchUserDataUseCase: FetchUserDataUseCase
    private let checkPasswordUseCase: CheckPasswordUseCase
    private let modifyUseCase: ModifyUseCase
    private (set)var currentStep: Int = 1
    private var userDTO: UserDTO? = nil
    var isCompleted: (Bool, Bool) = (false, false) {
        didSet {
            let isEnable = isCompleted.0 && isCompleted.1
            outputSubject.send(.updateButtonEnable(isEnable))
        }
    }
    
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
            case let .changePassword(password):
                self?.changePassword(password: password)
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
    
}

extension ChangePasswordViewModel {
    
    private func changePassword(password: String) {
        modifyUseCase.execute(requestModel: UserPutRequest(gender: userDTO?.gender, identity: nil, isGraduated: false, major: userDTO?.major, name: userDTO?.name, nickname: userDTO?.nickname, password: password, phoneNumber: userDTO?.phoneNumber, studentNumber: userDTO?.studentNumber)).sink { [weak self] completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
                self?.outputSubject.send(.showToast(error.message, false, false))
            }
        } receiveValue: { [weak self] _ in
            self?.outputSubject.send(.showToast("비밀번호 변경이 완료되었습니다.", true, true))
        }.store(in: &subscriptions)
    }
    
    private func fetchUserData() {
        fetchUserDataUseCase.execute().sink { [weak self] completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
                self?.outputSubject.send(.showToast(error.message, false, true))
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.showEmail(response.email ?? ""))
            self?.userDTO = response
        }.store(in: &subscriptions)
    }
    
    private func checkPassword(password: String) {
        checkPasswordUseCase.execute(password: password).sink { [weak self] completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
                self?.outputSubject.send(.showErrorMessage(error.message))
            }
        } receiveValue: { [weak self] response in
            self?.currentStep = 2
            self?.outputSubject.send(.passNextStep)
        }.store(in: &subscriptions)
    }
    
}

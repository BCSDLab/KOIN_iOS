//
//  RegisterViewModel.swift
//  koin
//
//  Created by 김나훈 on 3/18/24.
//

import Combine

final class RegisterViewModel: ViewModelProtocol {
    
    enum Input {
        case getDeptList
        case checkDuplicatedNickname(String)
        case tryRegister(UserRegisterRequest, String)
    }
    enum Output {
        case showHttpResult(String, SceneColorAsset)
        case changeCheckButtonStatus
        case showDeptDropDownList([String])
        case dissMissView
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let fetchDeptListUseCase: FetchDeptListUseCase
    private let registerUseCase: RegisterUseCase
    private let checkDuplicatedNicknameUseCase: CheckDuplicatedNicknameUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    
    init(fetchDeptListUseCase: FetchDeptListUseCase, registerUseCase: RegisterUseCase, checkDuplicatedNicknameUseCase: CheckDuplicatedNicknameUseCase, logAnalyticsEventUseCase: LogAnalyticsEventUseCase) {
        self.fetchDeptListUseCase = fetchDeptListUseCase
        self.registerUseCase = registerUseCase
        self.checkDuplicatedNicknameUseCase = checkDuplicatedNicknameUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case .getDeptList:
                self?.fetchDeptList()
            case let .checkDuplicatedNickname(nickname):
                self?.checkDuplicatedNickname(nickname: nickname)
            case let .tryRegister(request, passwordMatch):
                self?.register(registerRequest: request, passwordMatch: passwordMatch)
            }
        }.store(in: &subscriptions)
        
        return outputSubject.eraseToAnyPublisher()
    }
}

extension RegisterViewModel {
    
    private func register(registerRequest: UserRegisterRequest, passwordMatch: String) {
        registerUseCase.execute(requestModel: registerRequest, passwordMatch: passwordMatch).sink { [weak self] completion in
            if case let .failure(error) = completion {
                self?.outputSubject.send(.showHttpResult(error.message, .danger700))
            }
        } receiveValue: { [weak self] _ in
            self?.outputSubject.send(.dissMissView)
        }.store(in: &subscriptions)

    }
    private func fetchDeptList() {
        fetchDeptListUseCase.execute().sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.showDeptDropDownList(response))
        }.store(in: &subscriptions)
    }
    
    private func checkDuplicatedNickname(nickname: String) {
        checkDuplicatedNicknameUseCase.execute(nickname: nickname).sink { [weak self] completion in
            if case let .failure(error) = completion {
                self?.outputSubject.send(.showHttpResult(error.message, .danger700))
            }
        } receiveValue: { [weak self] _ in
            self?.outputSubject.send(.showHttpResult("사용 가능한 닉네임입니다", .neutral800))
            self?.outputSubject.send(.changeCheckButtonStatus)
        }.store(in: &subscriptions)
    }
    
    private func makeLogAnalyticsEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any) {
        logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
    }
    
}

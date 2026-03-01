//
//  ServiceSelectViewModel.swift
//  koin
//
//  Created by 김나훈 on 3/17/24.
//

import Combine

final class ServiceSelectViewModel: ViewModelProtocol {
    
    enum Input {
        case logOut
        case fetchUserData
        case logEvent(EventLabelType, EventParameter.EventCategory, Any)
    }
    enum Output {
        case disappearProfile
        case updateProfile(UserDto)
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private let fetchUserDataUseCase: FetchUserDataUseCase
    private var subscriptions: Set<AnyCancellable> = []
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private(set) var isLogined = false 
    
    init(fetchUserDataUseCase: FetchUserDataUseCase, logAnalyticsEventUseCase: LogAnalyticsEventUseCase) {
        self.fetchUserDataUseCase = fetchUserDataUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case .logOut:
                self?.logOut()
            case .fetchUserData:
                self?.fetchUserData()
            case let .logEvent(label, category, value):
                self?.makeLogAnalyticsEvent(label: label, category: category, value: value)
            }
            
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension ServiceSelectViewModel {
    
    private func fetchUserData() {
        fetchUserDataUseCase.execute().sink { [weak self] completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
                self?.isLogined = false
                self?.outputSubject.send(.disappearProfile)
            }
        } receiveValue: { [weak self] response in
            self?.isLogined = true
            self?.outputSubject.send(.updateProfile(response))
        }.store(in: &subscriptions)

    }
    
    private func logOut() {
        KeychainWorker.shared.delete(key: .access)
        KeychainWorker.shared.delete(key: .refresh)
        UserDataManager.shared.resetUserData()
        isLogined = false
        outputSubject.send(.disappearProfile)
    }
    
    private func makeLogAnalyticsEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any) {
        logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
    }
}

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
    private let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
    private let fetchUserDataUseCase: FetchUserDataUseCase = DefaultFetchUserDataUseCase(userRepository: DefaultUserRepository(service: DefaultUserService()))
    var shopId: Int = 0
    var shopName: String = ""
    var deleteParameter: (Int, Int) = (0, 0)

    
    enum Input {
        case checkLogin
        case logEvent(EventLabelType, EventParameter.EventCategory, Any)
    }
    enum Output {
        case updateLoginStatus(Bool)
    }
 
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case .checkLogin:
                self?.checkLogin()
            case let .logEvent(label, category, value):
                self?.makeLogAnalyticsEvent(label: label, category: category, value: value)
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
    
    private func makeLogAnalyticsEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any) {
        logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
    }
}

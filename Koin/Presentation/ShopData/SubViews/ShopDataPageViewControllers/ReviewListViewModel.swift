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
    var currentPage: Int = 0
    var totalPage: Int = 0
    var fetchLock: Bool = false
    
    enum Input {
        case checkLogin((Int, Int)?, source: LoginSource)
        case logEvent(EventLabelType, EventParameter.EventCategory, Any)
    }
    enum Output {
        case updateLoginStatus(Bool, (Int, Int)?)
    }
    enum LoginSource {
        case reviewWrite
        case reviewReport
    }
 
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case let .checkLogin(parameter, source):
                self?.checkLogin(parameter: parameter, source: source)
            case let .logEvent(label, category, value):
                self?.makeLogAnalyticsEvent(label: label, category: category, value: value)
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }

}

extension ReviewListViewModel {
    private func checkLogin(parameter: (Int, Int)?, source: LoginSource) {
        fetchUserDataUseCase.execute().sink { [weak self] completion in
            if case .failure = completion {
                self?.outputSubject.send(.updateLoginStatus(false, parameter))
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.updateLoginStatus(true, parameter))
            switch source {
                case .reviewWrite:
                    self?.makeLogAnalyticsEvent(label: EventParameter.EventLabel.Business.loginPrompt, category: .click, value: "리뷰 작성 팝업")
                case .reviewReport:
                    self?.makeLogAnalyticsEvent(label: EventParameter.EventLabel.Business.loginPrompt, category: .click, value: "리뷰 신고 팝업")
            }
        }.store(in: &subscriptions)
    }
    
    private func makeLogAnalyticsEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any) {
        logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
    }
}

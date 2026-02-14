//
//  ForceUpdateViewModel.swift
//  koin
//
//  Created by 김나훈 on 10/16/24.
//

import Combine

final class ForceUpdateViewModel: ViewModelProtocol {
    
    enum Input {
        case logEvent(EventLabelType, EventParameter.EventCategory, Any)
        case checkVersion
    }
    enum Output {
        case isLowVersion(Bool)
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private let checkVersionUseCase: CheckVersionUseCase
    
    init(logAnalyticsEventUseCase: LogAnalyticsEventUseCase, checkVersionUseCase: CheckVersionUseCase) {
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
        self.checkVersionUseCase = checkVersionUseCase
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case let .logEvent(label, category, value):
                self?.makeLogAnalyticsEvent(label: label, category: category, value: value)
            case .checkVersion:
                self?.checkVersion()
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
    
}

extension ForceUpdateViewModel {
    private func checkVersion() {
        checkVersionUseCase.execute().sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] response in
                self?.outputSubject.send(.isLowVersion(response.0))
            }
        ).store(in: &subscriptions)
    }

    
    private func makeLogAnalyticsEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any) {
        logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
    }
}

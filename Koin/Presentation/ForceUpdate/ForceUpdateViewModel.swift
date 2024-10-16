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
    }
    enum Output {
     
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    
    init(logAnalyticsEventUseCase: LogAnalyticsEventUseCase) {
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case let .logEvent(label, category, value):
                self?.makeLogAnalyticsEvent(label: label, category: category, value: value)
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
    
    private func makeLogAnalyticsEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any) {
        logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
    }
}

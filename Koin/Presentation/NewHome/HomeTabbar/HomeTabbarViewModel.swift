//
//  HomeTabbarViewModel.swift
//  koin
//
//  Created by Codex on 6/7/26.
//

import Combine

final class HomeTabbarViewModel: ViewModelProtocol {
    enum Input {
        case logEvent(EventLabelType, EventParameter.EventCategory, Any)
    }
    
    enum Output {}

    // MARK: - Properties
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []

    // MARK: - Initializer
    init(logAnalyticsEventUseCase: LogAnalyticsEventUseCase) {
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
    }

    // MARK: - Transform
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case let .logEvent(label, category, value):
                self?.makeLogAnalyticsEvent(label: label, category: category, value: value)
            }
        }.store(in: &subscriptions)
        
        return outputSubject.eraseToAnyPublisher()
    }
}

extension HomeTabbarViewModel {
    
    private func makeLogAnalyticsEvent(
        label: EventLabelType,
        category: EventParameter.EventCategory,
        value: Any
    ) {
        logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
    }
}

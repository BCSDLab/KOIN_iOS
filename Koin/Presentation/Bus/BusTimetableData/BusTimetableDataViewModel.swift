//
//  BusTimetableDataViewModel.swift
//  koin
//
//  Created by JOOMINKYUNG on 12/5/24.
//

import Combine

final class BusTimetableDataViewModel: ViewModelProtocol {

    enum Input {
        case getBusTimetable
        case logEvent(EventLabelType, Any)
    }

    enum Output {
        case updateBusRoute(ShuttleBusTimetable)
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let fetchShuttleTimetableUseCase: FetchShuttleBusTimetableUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private let shuttleRouteId: String
    
    init(fetchShuttleTimetableUseCase: FetchShuttleBusTimetableUseCase, logAnalyticsEventUseCase: LogAnalyticsEventUseCase, shuttleRouteId: String) {
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
        self.fetchShuttleTimetableUseCase = fetchShuttleTimetableUseCase
        self.shuttleRouteId = shuttleRouteId
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case .getBusTimetable:
                self?.getShuttleBusTimetable()
            case let .logEvent(label, value):
                self?.makeLogAnalyticsEvent(label: label, value: value)
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
    
    private func getShuttleBusTimetable() {
        fetchShuttleTimetableUseCase.execute(id: shuttleRouteId).sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] timetable in
                guard let self else { return }
                self.outputSubject.send(.updateBusRoute(timetable))
            }
        ).store(in: &subscriptions)
    }
    
    private func makeLogAnalyticsEvent(label: EventLabelType, value: Any) {
        logAnalyticsEventUseCase.execute(label: label, value: value)
    }
}


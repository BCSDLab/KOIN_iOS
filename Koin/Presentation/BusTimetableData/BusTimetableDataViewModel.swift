//
//  BusTimetableDataViewModel.swift
//  koin
//
//  Created by JOOMINKYUNG on 12/5/24.
//

import Combine
import Foundation

enum ShuttleTimetableType {
    case goSchool
    case dropOffSchool
    case manyRoute
}

final class BusTimetableDataViewModel: ViewModelProtocol {
    // MARK: - properties
    enum Input {
        case getBusTimetable(ShuttleTimetableType)
        case logEvent(EventLabelType, EventParameter.EventCategory, Any)
    }

    enum Output {
        case updateBusRoute(ShuttleBusTimetableDTO, ShuttleTimetableType)
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
            case let .getBusTimetable(shuttleTimetableType):
                self?.getShuttleBusTimetable(shuttleTimetableType: shuttleTimetableType)
            case let .logEvent(label, category, value):
                self?.makeLogAnalyticsEvent(label: label, category: category, value: value)
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
    
    private func getShuttleBusTimetable(shuttleTimetableType: ShuttleTimetableType) {
        fetchShuttleTimetableUseCase.execute(id: shuttleRouteId).sink(receiveCompletion: { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        }, receiveValue: { [weak self] timetable in
            self?.outputSubject.send(.updateBusRoute(timetable, shuttleTimetableType))
        }).store(in: &subscriptions)
    }
    
    private func makeLogAnalyticsEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any) {
        logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
    }
}


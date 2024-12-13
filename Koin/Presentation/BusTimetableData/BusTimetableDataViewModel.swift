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
    }

    enum Output {
        case updateBusRoute(ShuttleBusTimetableDTO, ShuttleTimetableType)
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let fetchShuttleTimetableUseCase: FetchShuttleBusTimetableUseCase
    private let shuttleRouteId: String
    
    init(fetchShuttleTimetableUseCase: FetchShuttleBusTimetableUseCase, shuttleRouteId: String) {
        self.fetchShuttleTimetableUseCase = fetchShuttleTimetableUseCase
        self.shuttleRouteId = shuttleRouteId
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case let .getBusTimetable(shuttleTimetableType):
                self?.getShuttleBusTimetable(shuttleTimetableType: shuttleTimetableType)
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
    
    private func getShuttleBusTimetable(shuttleTimetableType: ShuttleTimetableType) {
        print(shuttleRouteId)
        fetchShuttleTimetableUseCase.execute(id: shuttleRouteId).sink(receiveCompletion: { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        }, receiveValue: { [weak self] timetable in
            self?.outputSubject.send(.updateBusRoute(timetable, shuttleTimetableType))
        }).store(in: &subscriptions)
    }
}


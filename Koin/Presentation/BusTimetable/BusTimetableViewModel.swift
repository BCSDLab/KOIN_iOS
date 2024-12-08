//
//  BusTimetableViewModel.swift
//  koin
//
//  Created by JOOMINKYUNG on 2024/04/03.
//
import Combine
import Foundation

final class BusTimetableViewModel: ViewModelProtocol {
    enum Input {
        case getBusRoute(BusType)
        case getBusTimetable(BusType, Int, Int?)
    }

    enum Output {
        case updateBusRoute(busType: BusType, firstBusRoute: [String], secondBusRoute: [String]?)
        case updateBusTimetable(busType: BusType, busTimetableInfo: BusTimetableInfo)
        case updateShuttleBusRoutes(busRoutes: ShuttleRouteDTO)
    }
    
    // MARK: - properties
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let fetchExpressTimetableUseCase: FetchExpressTimetableUseCase
    private let getExpressFiltersUseCase: GetExpressFilterUseCase
    private let getCityFiltersUseCase: GetCityFiltersUseCase
    private let fetchCityTimetableUseCase: FetchCityBusTimetableUseCase
    private let getShuttleFilterUseCase: GetShuttleBusFilterUseCase
    private let fetchShuttleRoutesUseCase: FetchShuttleBusRoutesUseCase
    
    init(fetchExpressTimetableUseCase: FetchExpressTimetableUseCase, getExpressFiltersUseCase: GetExpressFilterUseCase, getCityFiltersUseCase: GetCityFiltersUseCase, fetchCityTimetableUseCase: FetchCityBusTimetableUseCase, getShuttleFilterUseCase: GetShuttleBusFilterUseCase, fetchShuttleRoutesUseCase: FetchShuttleBusRoutesUseCase) {
        self.fetchExpressTimetableUseCase = fetchExpressTimetableUseCase
        self.getExpressFiltersUseCase = getExpressFiltersUseCase
        self.getCityFiltersUseCase = getCityFiltersUseCase
        self.fetchCityTimetableUseCase = fetchCityTimetableUseCase
        self.getShuttleFilterUseCase = getShuttleFilterUseCase
        self.fetchShuttleRoutesUseCase = fetchShuttleRoutesUseCase
    }

    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case let .getBusRoute(busType):
                self?.getBusRoute(busType: busType)
            case let .getBusTimetable(busType, firstFilterIdx, secondFilterIdx):
                self?.getBusTimetable(busType: busType, firstFilterIdx: firstFilterIdx, secondFilterIdx: secondFilterIdx)
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
    
    private func getBusRoute(busType: BusType) {
        var firstBusRoute: [String] = []
        var secondBusRoute: [String]?
        switch busType {
        case .shuttleBus:
            firstBusRoute = getShuttleFilterUseCase.execute()
        case .expressBus:
            firstBusRoute = getExpressFiltersUseCase.execute()
        default:
            firstBusRoute = getCityFiltersUseCase.execute().0
            secondBusRoute = getCityFiltersUseCase.execute().1
        }
        outputSubject.send(.updateBusRoute(busType: busType, firstBusRoute: firstBusRoute, secondBusRoute: secondBusRoute))
    }
    
    private func getBusTimetable(busType: BusType, firstFilterIdx: Int, secondFilterIdx: Int?) {
        switch busType {
        case .shuttleBus:
            fetchShuttleRoutesUseCase.execute(busRouteType: ShuttleRouteType.allCases[firstFilterIdx]).sink(receiveCompletion: {
                completion in
                if case let .failure(error) = completion {
                    Log.make().error("\(error)")
                }
            }, receiveValue: { [weak self] busRoutes in
                self?.outputSubject.send(.updateShuttleBusRoutes(busRoutes: busRoutes))
            }).store(in: &subscriptions)
        case .expressBus:
            fetchExpressTimetableUseCase.execute(filterIdx: firstFilterIdx).sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    Log.make().error("\(error)")
                }
            }, receiveValue: { [weak self] timetable in
                self?.outputSubject.send(.updateBusTimetable(busType: busType, busTimetableInfo: timetable))
            }).store(in: &subscriptions)
        default:
            fetchCityTimetableUseCase.execute(firstFilterIdx: firstFilterIdx, secondFilterIdx: secondFilterIdx ?? 0).sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    Log.make().error("\(error)")
                }
            }, receiveValue: { [weak self] timetable in
                self?.outputSubject.send(.updateBusTimetable(busType: busType, busTimetableInfo: timetable))
            }).store(in: &subscriptions)
        }
    }
}

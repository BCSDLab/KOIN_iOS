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
        case getEmergencyNotice
        case logEvent(EventLabelType, EventParameter.EventCategory, Any)
    }

    enum Output {
        case updateBusRoute(busType: BusType, firstBusRoute: [String], secondBusRoute: [String]?)
        case updateBusTimetable(busType: BusType, busTimetableInfo: BusTimetableInfo)
        case updateShuttleBusRoutes(busRoutes: ShuttleRouteDTO)
        case updateEmergencyNotice(notice: BusNoticeDTO)
        case updateStopLabel(busStop: String)
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
    private let fetchEmergencyNoticeUseCase: FetchEmergencyNoticeUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    
    init(fetchExpressTimetableUseCase: FetchExpressTimetableUseCase, getExpressFiltersUseCase: GetExpressFilterUseCase, getCityFiltersUseCase: GetCityFiltersUseCase, fetchCityTimetableUseCase: FetchCityBusTimetableUseCase, getShuttleFilterUseCase: GetShuttleBusFilterUseCase, fetchShuttleRoutesUseCase: FetchShuttleBusRoutesUseCase, fetchEmergencyNoticeUseCase: FetchEmergencyNoticeUseCase, logAnalyticsEventUseCase: LogAnalyticsEventUseCase) {
        self.fetchExpressTimetableUseCase = fetchExpressTimetableUseCase
        self.getExpressFiltersUseCase = getExpressFiltersUseCase
        self.getCityFiltersUseCase = getCityFiltersUseCase
        self.fetchCityTimetableUseCase = fetchCityTimetableUseCase
        self.getShuttleFilterUseCase = getShuttleFilterUseCase
        self.fetchShuttleRoutesUseCase = fetchShuttleRoutesUseCase
        self.fetchEmergencyNoticeUseCase = fetchEmergencyNoticeUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
    }

    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case let .getBusRoute(busType):
                self?.getBusRoute(busType: busType)
            case let .getBusTimetable(busType, firstFilterIdx, secondFilterIdx):
                self?.getBusTimetable(busType: busType, firstFilterIdx: firstFilterIdx, secondFilterIdx: secondFilterIdx)
            case .getEmergencyNotice:
                self?.getEmergencyNotice()
            case let .logEvent(label, category, value):
                self?.makeLogAnalyticsEvent(label: label, category: category, value: value)
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
            }, receiveValue: { [weak self] timetable, busDirection in
                self?.outputSubject.send(.updateBusTimetable(busType: busType, busTimetableInfo: timetable))
                let busStop = busDirection == .from ? "천안 터미널 승차" : "코리아텍 승차"
                self?.outputSubject.send(.updateStopLabel(busStop: busStop))
            }).store(in: &subscriptions)
        default:
            fetchCityTimetableUseCase.execute(firstFilterIdx: firstFilterIdx, secondFilterIdx: secondFilterIdx ?? 0).sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    Log.make().error("\(error)")
                }
            }, receiveValue: { [weak self] timetable, busDirection in
                self?.outputSubject.send(.updateBusTimetable(busType: busType, busTimetableInfo: timetable))
                self?.outputSubject.send(.updateStopLabel(busStop: "\(busDirection) 승차"))
            }).store(in: &subscriptions)
        }
    }
    
    private func getEmergencyNotice() {
        fetchEmergencyNoticeUseCase.execute().sink(receiveCompletion: { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        }, receiveValue: { [weak self] notice in
            self?.outputSubject.send(.updateEmergencyNotice(notice: notice))
        }).store(in: &subscriptions)
    }
    
    private func makeLogAnalyticsEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any) {
        logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
    }
}

//
//  BusViewModel.swift
//  koin
//
//  Created by JOOMINKYUNG on 2024/04/03.
//
import Combine
import Foundation

struct SelectedBusPlaceStatus {
    let lastDepartedPlace: BusPlace?
    let nowDepartedPlace: BusPlace
    let lastArrivedPlace: BusPlace?
    let nowArrivedPlace: BusPlace
}

final class BusViewModel: ViewModelProtocol {
    
    enum Input {
        case changeBusRoute(selectedBusPlace: SelectedBusPlaceStatus)
        case getBusInfo(selectedBusPlace: SelectedBusPlaceStatus)
        case searchBusInfo(selectedBusPlace: SelectedBusPlaceStatus, date: Date, time: Date)
        case logEvent(EventLabelType, EventParameter.EventCategory, Any)
        case getBusFirstFilter
        case getBusSecondFilter(busType: BusType, firstBusFilterIdx: Int)
        case getBusTimetable(busType: BusType, firstBusFilterIdx: Int, secondBusFilterIdx: Int?)
    }

    enum Output {
        case setBusSearchedResult(busSearchedModel: SearchBusInfoResult)
        case updateBusRoute(departedPlaceStatus: BusPlace, arrivedPlaceStatus: BusPlace)
        case updateBusInfo(value: [BusCardInformation])
        case updateBusFirstFilter(busCourseModel: [BusCourseInfo], busType: BusType)
        case updateBusSecondFilter(busRouteModel: [String])
        case updateCityBusFilters(cityBusCourseModel: [CityBusCourseInfo])
        case updateBusTimetable(busTimetableModel: BusTimetableInfo, busType: BusType)
    }
    
    private let selectDepartureAndArrivalUseCase: SelectDepartAndArrivalUseCase
    private let searchBusInfoUseCase: SearchBusInfoUseCase
    private let fetchBusInfoUseCase: FetchBusInformationListUseCase
    private let getShuttleBusFiltersUseCase: GetShuttleBusFiltersUseCase
    private let getExpressFiltersUseCase: GetExpressFiltersUseCase
    private let getCityFiltersUseCase: GetCityFiltersUseCase
    private let fetchShuttleBusTimetableUseCase: FetchShuttleBusTimetableUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private let fetchExpressTimetableUseCase: FetchExpressTimetableUseCase
    private let fetchCityBusTimetableUseCase: FetchCityBusTimetableUseCase
    
    private let outputSubject: PassthroughSubject<Output, Never> = .init()
    private var cancellables: Set<AnyCancellable> = []
    
    init(selectDepartureAndArrivalUseCase: SelectDepartAndArrivalUseCase, fetchBusInfoUseCase: FetchBusInformationListUseCase, fetchShuttleBusTimetableUseCase: FetchShuttleBusTimetableUseCase, fetchExpressTimetableUseCase: FetchExpressTimetableUseCase, getShuttleBusFiltersUseCase: GetShuttleBusFiltersUseCase, getExpressBusFiltersUseCase: GetExpressFiltersUseCase, getCityBusFiltersUseCase: GetCityFiltersUseCase, fetchCityTimetableUseCase: FetchCityBusTimetableUseCase, searchBusInfoUseCase: SearchBusInfoUseCase, logAnalyticsEventUseCase: LogAnalyticsEventUseCase) {
        self.selectDepartureAndArrivalUseCase = selectDepartureAndArrivalUseCase
        self.fetchBusInfoUseCase = fetchBusInfoUseCase
        self.searchBusInfoUseCase = searchBusInfoUseCase
        self.fetchShuttleBusTimetableUseCase = fetchShuttleBusTimetableUseCase
        self.fetchExpressTimetableUseCase = fetchExpressTimetableUseCase
        self.fetchCityBusTimetableUseCase = fetchCityTimetableUseCase
        self.getShuttleBusFiltersUseCase = getShuttleBusFiltersUseCase
        self.getExpressFiltersUseCase = getExpressBusFiltersUseCase
        self.getCityFiltersUseCase = getCityBusFiltersUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
    }

    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        
        input.sink { [weak self] input in
            switch input {
            case .getBusInfo(let selectedBusPlace):
                self?.makeValidBusPlace(selectedBusPlace: selectedBusPlace)
                self?.fetchBusInfo(selectedBusPlace: selectedBusPlace)
            case .logEvent(let label, let category, let value):
                self?.makeLogAnalyticsEvent(label: label, category: category, value: value)
            case .changeBusRoute(let selectedBusPlace):
                self?.makeValidBusPlace(selectedBusPlace: selectedBusPlace)
            case .searchBusInfo(let selectedBusPlace, let date, let time):
                self?.searchBusInfo(selectedBusPlace: selectedBusPlace, date: date, time: time)
            case .getBusFirstFilter:
                self?.getBusFirstFilter()
            case .getBusTimetable(let busType, let firstBusFilterIdx, let secondBusFilterIdx):
                self?.fetchBusTimetableInfo(busType: busType, firstBusFilterIdx: firstBusFilterIdx, secondBusFilterIdx: secondBusFilterIdx)
            case .getBusSecondFilter(let busType, let firstBusFilterIdx):
                self?.getBusSecondFilter(busType: busType, firstBusFilterIdx: firstBusFilterIdx)
            }
            
        }.store(in: &cancellables)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension BusViewModel {
    
    private func makeValidBusPlace(selectedBusPlace: SelectedBusPlaceStatus) {
        let validDepartedPlace = selectDepartureAndArrivalUseCase.selectBusPlaceOptions(selectedBusPlace: selectedBusPlace).0
        let validArrivedPlace = selectDepartureAndArrivalUseCase.selectBusPlaceOptions(selectedBusPlace: selectedBusPlace).1
        self.outputSubject.send(.updateBusRoute(departedPlaceStatus: validDepartedPlace, arrivedPlaceStatus: validArrivedPlace))
    }
    
    private func fetchBusInfo(selectedBusPlace: SelectedBusPlaceStatus) {
        let validDepartedPlace = selectDepartureAndArrivalUseCase.selectBusPlaceOptions(selectedBusPlace: selectedBusPlace).0
        let validArrivedPlace = selectDepartureAndArrivalUseCase.selectBusPlaceOptions(selectedBusPlace: selectedBusPlace).1
        
        fetchBusInfoUseCase.execute(departedPlace: validDepartedPlace, arrivedPlace: validArrivedPlace).sink(receiveCompletion: { result in
            if case let .failure(error) = result {
                Log.make().error("\(error)")
            }
        }, receiveValue:  { [weak self] busInformation in
            self?.outputSubject.send(.updateBusInfo(value: busInformation))
        }).store(in: &cancellables)
    }
    
    private func searchBusInfo(selectedBusPlace: SelectedBusPlaceStatus, date: Date, time: Date) {
        let validDepartedPlace = selectDepartureAndArrivalUseCase.selectBusPlaceOptions(selectedBusPlace: selectedBusPlace).0
        let validArrivedPlace = selectDepartureAndArrivalUseCase.selectBusPlaceOptions(selectedBusPlace: selectedBusPlace).1
        
        let requestDate = date.formatDateToYYYYMMDD(separator: "-")
        let requestTime = time.formatDateToHHMM(isHH: true)
        let searchBusRequestModel = SearchBusInfoRequest(date: requestDate, time: requestTime, depart: validDepartedPlace.rawValue, arrival: validArrivedPlace.rawValue)
        searchBusInfoUseCase.execute(requestModel: searchBusRequestModel).sink(receiveCompletion: { result in
            if case let .failure(error) = result {
                Log.make().error("\(error)")
            }
        }, receiveValue: { [weak self] searchBusInfo in
            self?.outputSubject.send(.setBusSearchedResult(busSearchedModel: searchBusInfo))
        }).store(in: &cancellables)
    
    }
    
    private func getBusFirstFilter() {
        getShuttleBusFiltersUseCase.getBusFirstFilter().sink(receiveCompletion: { result in
            if case let .failure(error) = result {
                Log.make().error("\(error)")
            }
        }, receiveValue: { [weak self] firstFilter in
            self?.outputSubject.send(.updateBusFirstFilter(busCourseModel: firstFilter, busType: .shuttleBus))
        }).store(in: &cancellables)
    }
    
    private func getBusSecondFilter(busType: BusType, firstBusFilterIdx: Int) {
        switch busType {
        case .shuttleBus:
            getShuttleBusFiltersUseCase.getBusSecondFilter(firstFilterIdx: firstBusFilterIdx).sink(receiveCompletion: { result in
                if case let .failure(error) = result {
                    Log.make().error("\(error)")
                }
            }, receiveValue: { [weak self] secondFilters in
                self?.outputSubject.send(.updateBusSecondFilter(busRouteModel: secondFilters))
            }).store(in: &cancellables)
        default:
            let cityBusFilter = getCityFiltersUseCase.getBusFilter(busDirection: firstBusFilterIdx)
            self.outputSubject.send(.updateCityBusFilters(cityBusCourseModel: cityBusFilter))
        }
    }
    
    private func fetchBusTimetableInfo(busType: BusType, firstBusFilterIdx: Int, secondBusFilterIdx: Int?) {
        if let secondBusFilterIdx = secondBusFilterIdx {
            if busType == .shuttleBus {
                fetchShuttleBusTimetableUseCase.fetchShuttleBusTimetable(busFirstFilterIdx: firstBusFilterIdx, busSecondFilterIdx: secondBusFilterIdx).sink(receiveCompletion: { result in
                    if case let .failure(error) = result {
                        Log.make().error("\(error)")
                    }
                }, receiveValue: { [weak self] busTimetable in
                    self?.outputSubject.send(.updateBusTimetable(busTimetableModel: busTimetable, busType: .shuttleBus))
                }).store(in: &cancellables)
            }
            else {
                fetchCityBusTimetableUseCase.fetchCityBusTimetableUseCase(firstFilterIdx: firstBusFilterIdx, secondFilterIdx: secondBusFilterIdx).sink(receiveCompletion: { result in
                    if case let .failure(error) = result {
                        Log.make().error("\(error)")
                    }
                }, receiveValue: { [weak self] busTimetable in
                    self?.outputSubject.send(.updateBusTimetable(busTimetableModel: busTimetable, busType: .cityBus))
                }).store(in: &cancellables)
            }
        }
        else {
            fetchExpressTimetableUseCase.fetchExpressTimetable(firstFilterIdx: firstBusFilterIdx).sink(receiveCompletion: { result in
                if case let .failure(error) = result {
                    Log.make().error("\(error)")
                }
            }, receiveValue: { [weak self] busTimetable in
                self?.outputSubject.send(.updateBusTimetable(busTimetableModel: busTimetable, busType: .expressBus))
            }).store(in: &cancellables)
        }
    }
}

extension BusViewModel {
    private func makeLogAnalyticsEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any) {
        logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
    }
}

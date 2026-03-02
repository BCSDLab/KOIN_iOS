//
//  BusSearchResultViewModel.swift
//  koin
//
//  Created by JOOMINKYUNG on 11/10/24.
//

import Combine

final class BusSearchResultViewModel: ViewModelProtocol {
    enum Input {
        case getDatePickerData
        case getSearchedResult(String?, BusType?)
        case getSemesterInfo
        case logEvent(EventLabelType, EventParameter.EventCategory, Any)
    }
    enum Output {
        case updateDatePickerData(([[String]], [String]))
        case updateSemesterInfo(SemesterInfo)
        case udpatesSearchedResult(String?, SearchBusInfoResult)
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    let busPlaces: (BusPlace, BusPlace)  // navigationItem을 설정하기 위해 private 임시 없앰
    private var departBusType: BusType = .noValue
    private var departBusTime: String = ""
    private let fetchDatePickerDataUseCase: FetchKoinPickerDataUseCase
    private let fetchSearchedResultUseCase: SearchBusInfoUseCase
    private let fetchSemesterInfoUseCase: FetchShuttleBusRoutesUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    
    init(fetchDatePickerDataUseCase: FetchKoinPickerDataUseCase, busPlaces: (BusPlace, BusPlace), fetchSearchedResultUseCase: SearchBusInfoUseCase, fetchSemesterInfoUseCase: FetchShuttleBusRoutesUseCase, logAnalyticsEventUseCase: LogAnalyticsEventUseCase) {
        self.fetchDatePickerDataUseCase = fetchDatePickerDataUseCase
        self.fetchSearchedResultUseCase = fetchSearchedResultUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
        self.fetchSemesterInfoUseCase = fetchSemesterInfoUseCase
        self.busPlaces = busPlaces
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case .getDatePickerData:
                self?.getDatePickerData()
            case let .getSearchedResult(departDate, busType):
                self?.getSearchedResult(departDate: departDate, busType: busType)
            case let .logEvent(label, category, value):
                self?.makeLogAnalyticsEvent(label: label, category: category, value: value)
            case .getSemesterInfo:
                self?.getSemesterInfo()
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension BusSearchResultViewModel {
    private func getDatePickerData() {
        let data = fetchDatePickerDataUseCase.execute()
        outputSubject.send(.updateDatePickerData(data))
    }
    
    private func getSearchedResult(departDate: String?, busType: BusType?) {
        var departDateValue: String = ""
        var busTypeValue: BusType = .noValue
        if let departDate = departDate {
            departDateValue = departDate
            self.departBusTime = departDateValue
            busTypeValue = self.departBusType
        }
        else if let busType = busType {
            departDateValue = self.departBusTime
            self.departBusType = busType
            busTypeValue = busType
        }
        fetchSearchedResultUseCase.execute(date: departDateValue, busType: busTypeValue, departure: busPlaces.0, arrival: busPlaces.1).sink(receiveCompletion: { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        }, receiveValue: { [weak self] searchedResult in
            let output = departDate != nil ? (departDate, searchedResult) : (nil, searchedResult)
            self?.outputSubject.send(.udpatesSearchedResult(output.0, output.1))
        }).store(in: &subscriptions)
    }
    
    private func getSemesterInfo() {
        fetchSemesterInfoUseCase.execute(busRouteType: .overall).sink(receiveCompletion: { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        }, receiveValue: { [weak self] response in
            self?.outputSubject.send(.updateSemesterInfo(response.semesterInfo))
        }).store(in: &subscriptions)
    }
    
    private func makeLogAnalyticsEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any) {
        logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
    }
}

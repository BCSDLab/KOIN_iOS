//
//  BusSearchResultViewModel.swift
//  koin
//
//  Created by JOOMINKYUNG on 11/10/24.
//

import Combine
import Foundation

final class BusSearchResultViewModel: ViewModelProtocol {
    enum Input {
        case getSearchedResult(Date?, BusType?)
        case departNow
        case getSemesterInfo
        case logEvent(EventLabelType, EventParameter.EventCategory, Any)
    }
    enum Output {
        case updateSemesterInfo(SemesterInfo)
        case udpatesSearchedResult(Date?, SearchBusInfoResult)
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    let busPlaces: (BusPlace, BusPlace)  // navigationItem을 설정하기 위해 private 임시 없앰
    private var departBusType: BusType = .noValue
    /// 오늘/내일·날짜 목록 기준. 화면 진입 시 1회 고정, 지금 출발 시 갱신
    private(set) var now: Date
    private(set) var departDate: Date
    private let fetchSearchedResultUseCase: SearchBusInfoUseCase
    private let fetchSemesterInfoUseCase: FetchShuttleBusRoutesUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    
    init(busPlaces: (BusPlace, BusPlace), fetchSearchedResultUseCase: SearchBusInfoUseCase, fetchSemesterInfoUseCase: FetchShuttleBusRoutesUseCase, logAnalyticsEventUseCase: LogAnalyticsEventUseCase) {
        let now = Date()
        self.now = now
        self.departDate = now
        self.fetchSearchedResultUseCase = fetchSearchedResultUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
        self.fetchSemesterInfoUseCase = fetchSemesterInfoUseCase
        self.busPlaces = busPlaces
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case let .getSearchedResult(departDate, busType):
                self?.getSearchedResult(departDate: departDate, busType: busType)
            case .departNow:
                self?.departNow()
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
    /// departDate가 있으면 출발 시각 변경(버스 타입 유지), 없으면 버스 타입 변경(같은 departDate 재사용)
    private func getSearchedResult(departDate: Date?, busType: BusType?) {
        if let departDate = departDate {
            self.departDate = departDate
        }
        else if let busType = busType {
            self.departBusType = busType
        }
        fetchSearchedResultUseCase.execute(date: self.departDate, busType: departBusType, departure: busPlaces.0, arrival: busPlaces.1).sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] searchedResult in
                let output = departDate != nil ? (departDate, searchedResult) : (nil, searchedResult)
                self?.outputSubject.send(.udpatesSearchedResult(output.0, output.1))
            }
        ).store(in: &subscriptions)
    }
    
    /// 지금 출발: now 갱신 후 now로 재검색
    private func departNow() {
        now = Date()
        getSearchedResult(departDate: now, busType: nil)
    }
    
    private func getSemesterInfo() {
        fetchSemesterInfoUseCase.execute(busRouteType: .overall).sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] response in
                self?.outputSubject.send(.updateSemesterInfo(response.semesterInfo))
            }
        ).store(in: &subscriptions)
    }
    
    private func makeLogAnalyticsEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any) {
        logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
    }
}

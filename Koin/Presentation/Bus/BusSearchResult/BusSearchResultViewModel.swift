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
        /// 모달 열기 직전. 날짜가 바뀐 경우에만 now 갱신
        case refreshNowIfDayChanged
        case getSemesterInfo
        case logEvent(LegacyEventLabelType, EventParameter.EventCategory, Any)
    }
    enum Output {
        case updateSemesterInfo(SemesterInfo)
        /// 출발 시각(trigger) 갱신. 검색 결과와 무관하게 departDate·now가 바뀌는 즉시 발행
        case updateDepartDate(Date, now: Date)
        case udpatesSearchedResult(SearchBusInfoResult)
        /// 검색 실패: 이전 결과와 새 조건이 섞이지 않도록 목록 비움
        case clearSearchedResult
        /// 최신 검색 완료(성공·실패)
        case searchCompleted
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    /// 진행 중인 검색. 새 검색 시 취소
    private var searchCancellable: AnyCancellable?
    let busPlaces: (BusPlace, BusPlace)  // navigationItem을 설정하기 위해 private 임시 없앰
    private var departBusType: BusType = .noValue
    /// 오늘/내일·날짜 목록 기준. 화면 진입 시 1회 고정, 지금 출발·새로고침·날짜 변경 시 갱신
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
            case .refreshNowIfDayChanged:
                self?.refreshNowIfDayChanged()
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
        refreshNowIfDayChanged()
        if let departDate = departDate {
            self.departDate = departDate
            outputSubject.send(.updateDepartDate(departDate, now: now))
        }
        else if let busType = busType {
            self.departBusType = busType
        }
        
        searchCancellable?.cancel()
        searchCancellable = fetchSearchedResultUseCase.execute(date: self.departDate, busType: departBusType, departure: busPlaces.0, arrival: busPlaces.1)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    if case .failure = completion {
                        outputSubject.send(.clearSearchedResult)
                    }
                    outputSubject.send(.searchCompleted)
                },
                receiveValue: { [weak self] searchedResult in
                    guard let self else { return }
                    outputSubject.send(.udpatesSearchedResult(searchedResult))
                }
            )
    }
    
    /// 지금 출발·새로고침: now 갱신 후 now로 재검색
    private func departNow() {
        now = Date()
        getSearchedResult(departDate: now, busType: nil)
    }
    
    /// 자정이 지나 now가 어제면 갱신 후 출발 시각 문구 재표시(자체 재검색 없음). 같은 날은 유지, departDate는 모달 picker가 범위로 보정
    private func refreshNowIfDayChanged() {
        if !Calendar.koin.isDate(now, inSameDayAs: Date()) {
            now = Date()
            outputSubject.send(.updateDepartDate(departDate, now: now))
        }
    }
    
    private func getSemesterInfo() {
        fetchSemesterInfoUseCase.execute(busRouteType: .overall).sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] response in
                self?.outputSubject.send(.updateSemesterInfo(response.semesterInfo))
            }
        ).store(in: &subscriptions)
    }
    
    private func makeLogAnalyticsEvent(label: LegacyEventLabelType, category: EventParameter.EventCategory, value: Any) {
        logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
    }
}

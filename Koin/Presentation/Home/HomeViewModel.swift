//
//  HomeViewModel.swift
//  Koin
//
//  Created by 김나훈 on 3/10/24.
//

import Combine
import Foundation

final class HomeViewModel: ViewModelProtocol {
    
    // MARK: - Input
    
    enum Input {
        case viewDidLoad
        case categorySelected(DiningPlace)
        case getBusInfo(BusPlace, BusPlace, BusType)
        case getDiningInfo
        case logEvent(EventLabelType, EventParameter.EventCategory, Any, String? = nil, String? = nil, ScreenActionType? = nil, EventParameter.EventLabelNeededDuration? = nil)
        case getUserScreenAction(Date, ScreenActionType, EventParameter.EventLabelNeededDuration? = nil)
        case getNoticeBanner(Date)
        case getAbTestResult(String)
    }
    
    // MARK: - Output
    
    enum Output {
        case updateDining(DiningItem?, DiningType, Bool)
        case updateBus(BusCardInformation)
        case updateNoticeBanners([NoticeArticleDTO], (String, String))
        case putImage(ShopCategoryDTO)
        case showForceUpdate(String)
        case moveBusItem
        case setAbTestResult(AssignAbTestResponse)
    }
    
    // MARK: - Properties
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private let fetchDiningListUseCase: FetchDiningListUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private let fetchShopCategoryListUseCase: FetchShopCategoryListUseCase
    private let dateProvider: DateProvider
    private let fetchBusInformationListUseCase: FetchBusInformationListUseCase
    private let checkVersionUseCase: CheckVersionUseCase
    private let getUserScreenTimeUseCase: GetUserScreenTimeUseCase
    private let fetchHotNoticeArticlesUseCase: FetchHotNoticeArticlesUseCase
    private let assignAbTestUseCase: AssignAbTestUseCase
    private let fetchKeywordNoticePhraseUseCase: FetchKeywordNoticePhraseUseCase
    private var subscriptions: Set<AnyCancellable> = []
    private (set) var moved = false
    
    // MARK: - Initialization
    init(fetchDiningListUseCase: FetchDiningListUseCase,
         logAnalyticsEventUseCase: LogAnalyticsEventUseCase,
         getUserScreenTimeUseCase: GetUserScreenTimeUseCase,
         fetchBusInformationListUseCase: FetchBusInformationListUseCase,
         fetchHotNoticeArticlesUseCase: FetchHotNoticeArticlesUseCase,
         fetchShopCategoryListUseCase: FetchShopCategoryListUseCase,
         dateProvider: DateProvider, checkVersionUseCase: CheckVersionUseCase, assignAbTestUseCase: AssignAbTestUseCase, fetchKeywordNoticePhraseUseCase: FetchKeywordNoticePhraseUseCase) {
        self.fetchDiningListUseCase = fetchDiningListUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
        self.getUserScreenTimeUseCase = getUserScreenTimeUseCase
        self.fetchBusInformationListUseCase = fetchBusInformationListUseCase
        self.fetchHotNoticeArticlesUseCase = fetchHotNoticeArticlesUseCase
        self.fetchShopCategoryListUseCase = fetchShopCategoryListUseCase
        self.dateProvider = dateProvider
        self.checkVersionUseCase = checkVersionUseCase
        self.assignAbTestUseCase = assignAbTestUseCase
        self.fetchKeywordNoticePhraseUseCase = fetchKeywordNoticePhraseUseCase
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case .viewDidLoad:
                self?.getBusInformation(.koreatech, .terminal, .shuttleBus)
                self?.getShopCategory()
                self?.checkVersion()
            case let .categorySelected(place):
                self?.getDiningInformation(diningPlace: place)
            case let .getBusInfo(from, to, type):
                self?.getBusInformation(from, to, type)
            case .getDiningInfo:
                self?.getDiningInformation()
            case let .logEvent(label, category, value, previousPage, currentPage, durationType, eventLabelNeededDuration):
                self?.makeLogAnalyticsEvent(label: label, category: category, value: value, previousPage: previousPage, currentPage: currentPage, screenActionType: durationType, eventLabelNeededDuration: eventLabelNeededDuration)
            case let .getUserScreenAction(time, screenActionType, eventLabelNeededDuration):
                self?.getScreenAction(time: time, screenActionType: screenActionType, eventLabelNeededDuration: eventLabelNeededDuration)
            case let .getNoticeBanner(date):
                self?.getNoticeBanners(date: date)
            case let .getAbTestResult(abTestTitle):
                self?.getAbTestResult(abTestTitle: abTestTitle)
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
    
}

extension HomeViewModel {
    
    private func checkVersion() {
        checkVersionUseCase.execute().sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            if response.0 {
                self?.outputSubject.send(.showForceUpdate(response.1))
            }
        }.store(in: &subscriptions)

    }
    
    // TODO: 아직 버스 리팩토링이 완료되지 않았으므로 여기서 Alamofire 호출.
    private func getBusInformation(_ from: BusPlace, _ to: BusPlace, _ type: BusType) {
        
        fetchBusInformationListUseCase.execute(departedPlace: from, arrivedPlace: to).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            guard let self = self else { return }
            if let filteredResponse = response.filter({ $0.busTitle == type }).first {
                if !self.moved {
                    outputSubject.send(.moveBusItem)
                    self.moved = true
                }
                self.outputSubject.send(.updateBus(filteredResponse))
            }
        }.store(in: &subscriptions)
        
    }
    
    private func getDiningInformation(diningPlace: DiningPlace = .cornerA) {
        let dateInfo = dateProvider.execute(date: Date())
        
        fetchDiningListUseCase.execute(diningInfo: dateInfo).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            let result = response.filter { $0.place == diningPlace }.first
            self?.outputSubject.send(.updateDining(result, dateInfo.diningType, dateInfo.date.formatDateToYYMMDD() == Date().formatDateToYYMMDD()))
        }.store(in: &subscriptions)
    }
    
    private func getShopCategory() {
           fetchShopCategoryListUseCase.execute().sink { completion in
               if case let .failure(error) = completion {
                   Log.make().error("\(error)")
               }
           } receiveValue: { [weak self] response in
               self?.outputSubject.send(.putImage(response))
           }.store(in: &subscriptions)
       }

    private func makeLogAnalyticsEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any, previousPage: String? = nil, currentPage: String? = nil, screenActionType: ScreenActionType? = nil, eventLabelNeededDuration: EventParameter.EventLabelNeededDuration? = nil) {
        if eventLabelNeededDuration != nil {
            var durationTime = getUserScreenTimeUseCase.returnUserScreenTime(isEventTime: false)
            if eventLabelNeededDuration == .mainShopBenefit {
                durationTime = getUserScreenTimeUseCase.returnUserScreenTime(isEventTime: true)
            }
            
            logAnalyticsEventUseCase.executeWithDuration(label: label, category: category, value: value, previousPage: previousPage, currentPage: currentPage, durationTime: "\(durationTime)")
        }
        else {
            logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
        }
    }
    
    private func getScreenAction(time: Date, screenActionType: ScreenActionType, eventLabelNeededDuration: EventParameter.EventLabelNeededDuration? = nil) {
        getUserScreenTimeUseCase.getUserScreenAction(time: time, screenActionType: screenActionType, screenEventLabel: eventLabelNeededDuration)
    }
    
    private func getNoticeBanners(date: Date) {
        let phrase = fetchKeywordNoticePhraseUseCase.execute(date: date)
        fetchHotNoticeArticlesUseCase.execute(noticeId: nil).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] articles in
            self?.outputSubject.send(.updateNoticeBanners(articles, phrase))
        }.store(in: &subscriptions)
    }
    
    private func getAbTestResult(abTestTitle: String) {
        assignAbTestUseCase.execute(requestModel: AssignAbTestRequest(title: abTestTitle)).sink(receiveCompletion: { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        }, receiveValue: { [weak self] abTestResult in
            print(abTestResult)
            self?.outputSubject.send(.setAbTestResult(abTestResult))
        }).store(in: &subscriptions)
    }
}



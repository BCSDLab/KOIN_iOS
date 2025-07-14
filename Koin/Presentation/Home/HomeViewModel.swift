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
        case getDiningInfo
        case logEvent(EventLabelType, EventParameter.EventCategory, Any, String? = nil, String? = nil, ScreenActionType? = nil, EventParameter.EventLabelNeededDuration? = nil)
        case getUserScreenAction(Date, ScreenActionType, EventParameter.EventLabelNeededDuration? = nil)
        case getNoticeBanner(Date?)
        case getAbTestResult(String)
    }
    
    // MARK: - Output
    
    enum Output {
        case updateDining(DiningItem?, DiningType, Bool)
        case updateNoticeBanners([NoticeArticleDTO], ((String, String), Int)?)
        case putImage(ShopCategoryDTO)
        case showForceUpdate(String)
        case setAbTestResult(AssignAbTestResponse)
        case showForceModal
    }
    
    // MARK: - Properties
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private let fetchDiningListUseCase: FetchDiningListUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private let fetchShopCategoryListUseCase: FetchShopCategoryListUseCase
    private let dateProvider: DateProvider
    private let checkVersionUseCase: CheckVersionUseCase
    private let getUserScreenTimeUseCase: GetUserScreenTimeUseCase
    private let fetchHotNoticeArticlesUseCase: FetchHotNoticeArticlesUseCase
    private let assignAbTestUseCase: AssignAbTestUseCase
    private let fetchKeywordNoticePhraseUseCase: FetchKeywordNoticePhraseUseCase
    private let fetchUserDataUseCase = DefaultFetchUserDataUseCase(userRepository: DefaultUserRepository(service: DefaultUserService()))
    private var subscriptions: Set<AnyCancellable> = []
    private (set) var moved = false
    
    // MARK: - Initialization
    init(fetchDiningListUseCase: FetchDiningListUseCase,
         logAnalyticsEventUseCase: LogAnalyticsEventUseCase,
         getUserScreenTimeUseCase: GetUserScreenTimeUseCase,
         fetchHotNoticeArticlesUseCase: FetchHotNoticeArticlesUseCase,
         fetchShopCategoryListUseCase: FetchShopCategoryListUseCase,
         dateProvider: DateProvider, checkVersionUseCase: CheckVersionUseCase, assignAbTestUseCase: AssignAbTestUseCase, fetchKeywordNoticePhraseUseCase: FetchKeywordNoticePhraseUseCase) {
        self.fetchDiningListUseCase = fetchDiningListUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
        self.getUserScreenTimeUseCase = getUserScreenTimeUseCase
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
                self?.getShopCategory()
                self?.checkVersion()
                self?.fetchUserData()
            case let .categorySelected(place):
                self?.getDiningInformation(diningPlace: place)
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
    private func fetchUserData() {
        fetchUserDataUseCase.execute().sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            UserDataManager.shared.setUserData(userData: response)
            if UserDefaults.standard.bool(forKey: "forceModal") {
                if response.userType == "STUDENT" {
                    if response.name == nil ||
                        response.phoneNumber == nil ||
                        response.gender == nil ||
                        response.major == nil ||
                        response.studentNumber == nil {
                        self?.outputSubject.send(.showForceModal)
                        UserDefaults.standard.set(true, forKey: "forceModal")
                    }
                }
                self?.outputSubject.send(.showForceModal)
            }
        }.store(in: &subscriptions)
    }
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
            if eventLabelNeededDuration == .mainShopBenefit || eventLabelNeededDuration == .benefitShopCategories {
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
    
    private func getNoticeBanners(date: Date?) {
        var phrase: ((String, String), Int) = (("", ""), 0)
        if let date = date {
            phrase = fetchKeywordNoticePhraseUseCase.execute(date: date)
        }
        fetchHotNoticeArticlesUseCase.execute(noticeId: nil).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] articles in
            if date == nil {
                self?.outputSubject.send(.updateNoticeBanners(articles, nil))
            }
            else {
                self?.outputSubject.send(.updateNoticeBanners(articles, phrase))
            }
        }.store(in: &subscriptions)
    }
    
    private func getAbTestResult(abTestTitle: String) {
        assignAbTestUseCase.execute(requestModel: AssignAbTestRequest(title: abTestTitle))
            .throttle(for: .milliseconds(500), scheduler: RunLoop.main, latest: true)
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    Log.make().error("\(error)")
                    if abTestTitle == "c_keyword_ banner_v1" {
                        self?.getNoticeBanners(date: nil)
                    }
                }
            }, receiveValue: { [weak self] abTestResult in
                print(abTestResult)
                self?.outputSubject.send(.setAbTestResult(abTestResult))
                if abTestTitle == "c_main_dining_v1" {
                    self?.getAbTestResult(abTestTitle: "c_keyword_ banner_v1")
                }
            }).store(in: &subscriptions)
    }
}



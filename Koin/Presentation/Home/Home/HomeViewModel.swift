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
        case getLostItemStat
        case logEvent(EventLabelType, EventParameter.EventCategory, Any, String? = nil, String? = nil, ScreenActionType? = nil, EventParameter.EventLabelNeededDuration? = nil)
        case logEventDirect(name: String, label: String, value: String, category: String)
        case getUserScreenAction(Date, ScreenActionType, EventParameter.EventLabelNeededDuration? = nil)
        case getNoticeBanner(Date?)
        case fetchBanner
        case checkLogin
        case checkRestriction
        case logSessionEvent(EventLabelType, EventParameter.EventCategory, Any, String)
    }
    
    // MARK: - Output
    
    enum Output {
        case updateDining(DiningItem?, DiningType, Bool)
        case updateNoticeBanners([NoticeArticleDto], ((String, String), Int)?)
        case putImage(ShopCategoryDto)
        case showForceUpdate(String)
        case showForceModal
        case updateBanner(BannerDto)
        case updateLostItem(LostItemStats)
        case checkRestrictionCompleted(isRestricted: Bool, type: RestrictionType?, until: String?)
    }
    
    // MARK: - Properties
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private let fetchDiningListUseCase: FetchDiningListUseCase
    let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private let fetchShopCategoryListUseCase: FetchShopCategoryListUseCase
    private let dateProvider: DateProvider
    private let checkVersionUseCase: CheckVersionUseCase
    private let getUserScreenTimeUseCase: GetUserScreenTimeUseCase
    private let fetchHotNoticeArticlesUseCase: FetchHotNoticeArticlesUseCase
    private let fetchKeywordNoticePhraseUseCase: FetchKeywordNoticePhraseUseCase
    private let fetchLostItemStatsUseCase: FetchLostItemStatsUseCase
    private let fetchUserDataUseCase = DefaultFetchUserDataUseCase(userRepository: DefaultUserRepository(service: DefaultUserService()))
    private let fetchBannerUseCase = DefaultFetchBannerUseCase(coreRepository: DefaultCoreRepository(service: DefaultCoreService()))
    private let fetchCallVanRestrictionUseCase: FetchCallVanRestrictionUseCase
    private let checkLoginUseCase: CheckLoginUseCase
    private var subscriptions: Set<AnyCancellable> = []
    private(set) var moved = false
    private var shopCategories: [ShopCategory] = []
    private(set) var isLoggedIn: Bool = false
    
    // MARK: - Initialization
    init(fetchDiningListUseCase: FetchDiningListUseCase,
         logAnalyticsEventUseCase: LogAnalyticsEventUseCase,
         getUserScreenTimeUseCase: GetUserScreenTimeUseCase,
         fetchHotNoticeArticlesUseCase: FetchHotNoticeArticlesUseCase,
         fetchShopCategoryListUseCase: FetchShopCategoryListUseCase,
         dateProvider: DateProvider,
         checkVersionUseCase: CheckVersionUseCase,
         fetchKeywordNoticePhraseUseCase: FetchKeywordNoticePhraseUseCase,
         checkLoginUseCase: CheckLoginUseCase,
         fetchLostItemStatsUseCase: FetchLostItemStatsUseCase,
         fetchCallVanRestrictionUseCase: FetchCallVanRestrictionUseCase
    ) {
        self.fetchDiningListUseCase = fetchDiningListUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
        self.getUserScreenTimeUseCase = getUserScreenTimeUseCase
        self.fetchHotNoticeArticlesUseCase = fetchHotNoticeArticlesUseCase
        self.fetchShopCategoryListUseCase = fetchShopCategoryListUseCase
        self.dateProvider = dateProvider
        self.checkVersionUseCase = checkVersionUseCase
        self.fetchKeywordNoticePhraseUseCase = fetchKeywordNoticePhraseUseCase
        self.checkLoginUseCase = checkLoginUseCase
        self.fetchLostItemStatsUseCase = fetchLostItemStatsUseCase
        self.fetchCallVanRestrictionUseCase = fetchCallVanRestrictionUseCase
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
            case .getLostItemStat:
                self?.getLostItemStat()
            case let .logEvent(label, category, value, previousPage, currentPage, durationType, eventLabelNeededDuration):
                self?.makeLogAnalyticsEvent(label: label, category: category, value: value, previousPage: previousPage, currentPage: currentPage, screenActionType: durationType, eventLabelNeededDuration: eventLabelNeededDuration)
            case let .getUserScreenAction(time, screenActionType, eventLabelNeededDuration):
                self?.getScreenAction(time: time, screenActionType: screenActionType, eventLabelNeededDuration: eventLabelNeededDuration)
            case let .getNoticeBanner(date):
                self?.getNoticeBanners(date: date)
            case .fetchBanner:
                self?.fetchBanner()
            case .checkLogin:
                self?.checkLogin()
            case let .logEventDirect(name, label, value, category):
                self?.logAnalyticsEventUseCase.logEvent(name: name, label: label, value: value, category: category)
            case let .logSessionEvent(label, category, value, sessionId):
                self?.makeLogAnalyticsSessionEvent(label: label, category: category, value: value, sessionId: sessionId)
            case .checkRestriction:
                self?.checkRestriction()
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
    
}

extension HomeViewModel {
    
    private func fetchBanner() {
        fetchBannerUseCase.execute().sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] response in
                self?.outputSubject.send(.updateBanner(response))
            }
        ).store(in: &subscriptions)
    }
    
    private func fetchUserData() {
        fetchUserDataUseCase.execute().sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] response in
                UserDataManager.shared.setUserData(userData: response)
                if !UserDefaults.standard.bool(forKey: "forceModal") {
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
                }
            }
        ).store(in: &subscriptions)
    }
    private func checkVersion() {
        checkVersionUseCase.execute().sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] response in
                if response.0 {
                    self?.outputSubject.send(.showForceUpdate(response.1))
                }
            }
        ).store(in: &subscriptions)
    }
    
    private func getDiningInformation(diningPlace: DiningPlace = .cornerA) {
        let dateInfo = dateProvider.execute(date: Date())
        
        fetchDiningListUseCase.execute(diningInfo: dateInfo).sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] response in
                let result = response.filter { $0.place == diningPlace }.first
                self?.outputSubject.send(.updateDining(result, dateInfo.diningType, dateInfo.date.formatDateToYYMMDD() == Date().formatDateToYYMMDD()))
            }
        ).store(in: &subscriptions)
    }
    
    private func getLostItemStat() {
        fetchLostItemStatsUseCase.execute().sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] lostItemStats in
                self?.outputSubject.send(.updateLostItem(lostItemStats))
            }
        ).store(in: &subscriptions)
    }
    
    private func getShopCategory() {
        fetchShopCategoryListUseCase.execute().sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] response in
                self?.shopCategories = response.shopCategories
                self?.outputSubject.send(.putImage(response))
            }
        ).store(in: &subscriptions)
    }
    
    func getCategoryName(for id: Int) -> String? {
        return shopCategories.first(where: { $0.id == id })?.name
    }
    
    private func checkLogin() {
        checkLoginUseCase.execute()
            .sink { isLoggedIn in
                self.isLoggedIn = isLoggedIn
                UserDefaults.standard.set(isLoggedIn ? 1 : 0, forKey: "loginFlag")
            }
            .store(in: &subscriptions)
    }
    
    private func makeLogAnalyticsEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any, previousPage: String? = nil, currentPage: String? = nil, screenActionType: ScreenActionType? = nil, eventLabelNeededDuration: EventParameter.EventLabelNeededDuration? = nil) {
        if eventLabelNeededDuration != nil {
            var durationTime = getUserScreenTimeUseCase.returnUserScreenTime(isEventTime: false)
            if eventLabelNeededDuration == .mainShopBenefit || eventLabelNeededDuration == .benefitShopCategories || eventLabelNeededDuration == .mainShopCategories {
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
        fetchHotNoticeArticlesUseCase.execute(noticeId: nil).sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] articles in
                if date == nil {
                    self?.outputSubject.send(.updateNoticeBanners(articles, nil))
                }
                else {
                    self?.outputSubject.send(.updateNoticeBanners(articles, phrase))
                }
            }
        ).store(in: &subscriptions)
    }
  
    private func checkRestriction() {
        fetchCallVanRestrictionUseCase.execute().sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] restriction in
                self?.outputSubject.send(.checkRestrictionCompleted(
                    isRestricted: restriction.isRestricted,
                    type: restriction.restrictionType,
                    until: restriction.restrictedUntil))
            }
        ).store(in: &subscriptions)
    }
    
    private func makeLogAnalyticsSessionEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any, sessionId: String) {
        logAnalyticsEventUseCase.executeWithSessionId(label: label, category: category, value: value, sessionId: sessionId)
    }
}

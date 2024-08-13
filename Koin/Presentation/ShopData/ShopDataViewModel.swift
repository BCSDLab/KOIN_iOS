//
//  ShopDataViewModel.swift
//  koin
//
//  Created by 김나훈 on 3/13/24.
//

import Combine
import Foundation

final class ShopDataViewModel: ViewModelProtocol {
        
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let shopId: Int
    private let categoryId: Int?
    private let fetchShopDataUseCase: FetchShopDataUseCase
    private let fetchShopMenuListUseCase: FetchShopMenuListUseCase
    private let fetchShopEventListUseCase: FetchShopEventListUseCase
    private let fetchShopReviewListUseCase: FetchShopReviewListUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private let getUserScreenTimeUseCase: GetUserScreenTimeUseCase
    private (set) var eventItem: [ShopEvent] = []
    private (set) var menuItem: [MenuCategory] = []
    
    enum Input {
        case viewDidLoad
        case fetchShopEventList
        case fetchShopMenuList
        case fetchShopReviewList
        case logEvent(EventLabelType, EventParameter.EventCategory, Any, String? = nil, ScreenActionType? = nil, EventParameter.EventLabelNeededDuration? = nil)
        case getUserScreenAction(Date, ScreenActionType, EventParameter.EventLabelNeededDuration? = nil)
    }
    enum Output {
        case showShopData(ShopData)
        case showShopMenuList([MenuCategory])
        case showShopEventList([ShopEvent])
        case showShopReviewList(ShopReview)
    }
    
    init(fetchShopDataUseCase: FetchShopDataUseCase, fetchShopMenuListUseCase: FetchShopMenuListUseCase, fetchShopEventListUseCase: FetchShopEventListUseCase, fetchShopReviewListUseCase: FetchShopReviewListUseCase, logAnalyticsEventUseCase: LogAnalyticsEventUseCase, getUserScreenTimeUseCase: GetUserScreenTimeUseCase, shopId: Int, categoryId: Int?) {
        self.fetchShopDataUseCase = fetchShopDataUseCase
        self.fetchShopMenuListUseCase = fetchShopMenuListUseCase
        self.fetchShopEventListUseCase = fetchShopEventListUseCase
        self.fetchShopReviewListUseCase = fetchShopReviewListUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
        self.getUserScreenTimeUseCase = getUserScreenTimeUseCase
        self.shopId = shopId
        self.categoryId = categoryId
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case .viewDidLoad:
                self?.fetchShopData()
                self?.fetchShopMenuList()
            case let .logEvent(label, category, value, currentPage, screenActionType, eventLabelNeededDuration):
                self?.makeLogAnalyticsEvent(label: label, category: category, value: value, currentPage: currentPage, screenActionType: screenActionType, eventLabelNeededDuration: eventLabelNeededDuration)
            case .fetchShopEventList:
                self?.fetchShopEventList()
            case .fetchShopMenuList:
                self?.fetchShopMenuList()
            case .fetchShopReviewList:
                self?.fetchShopReviewList()
            case let .getUserScreenAction(time, screenActionType, eventLabelNeededDuration):
                self?.getScreenAction(time: time, screenActionType: screenActionType, eventLabelNeededDuration: eventLabelNeededDuration)
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension ShopDataViewModel {
    
    private func fetchShopReviewList() {
        fetchShopReviewListUseCase.execute().sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.showShopReviewList(response))
        }.store(in: &subscriptions)
    }
    
    private func fetchShopData() {
        fetchShopDataUseCase.execute(shopId: shopId).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.showShopData(response))
        }.store(in: &subscriptions)
    }
    
    private func fetchShopMenuList() {
        fetchShopMenuListUseCase.execute(shopId: shopId).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            self?.menuItem = response
            self?.outputSubject.send(.showShopMenuList(response))
        }.store(in: &subscriptions)
    }
    
    private func fetchShopEventList() {
        fetchShopEventListUseCase.execute(shopId: shopId).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            self?.eventItem = response
            self?.outputSubject.send(.showShopEventList(response))
        }.store(in: &subscriptions)
    }
    
    private func makeLogAnalyticsEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any, previousPage: String? = nil, currentPage: String? = nil, screenActionType: ScreenActionType? = nil, eventLabelNeededDuration: EventParameter.EventLabelNeededDuration? = nil) {
        if eventLabelNeededDuration != nil {
            let durationTime = getUserScreenTimeUseCase.returnUserScreenTime(isEventTime: true)
            
            logAnalyticsEventUseCase.executeWithDuration(label: label, category: category, value: value, previousPage: previousPage, currentPage: currentPage, durationTime: "\(durationTime)")
        }
        else {
            logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
        }
    }
    
    private func getScreenAction(time: Date, screenActionType: ScreenActionType, eventLabelNeededDuration: EventParameter.EventLabelNeededDuration? = nil) {
        getUserScreenTimeUseCase.getUserScreenAction(time: time, screenActionType: screenActionType, screenEventLabel: eventLabelNeededDuration)
    }
}

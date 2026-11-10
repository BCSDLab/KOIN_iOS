//
//  ShopSummaryViewModel.swift
//  koin
//
//  Created by 홍기정 on 9/5/25.
//

import Combine
import Foundation

final class ShopSummaryViewModel {
    
    // MARK: - Input
    enum Input {
        case viewDidLoad
        case logEvent(LegacyEventLabelType, EventParameter.EventCategory, Any, String? = nil, String? = nil, ScreenActionType? = nil, EventParameter.EventLabelNeededDuration? = nil)
        case logEventDirect(LegacyEventLabelType, EventParameter.EventCategory, Any)
        case getUserScreenAction(Date, ScreenActionType, EventParameter.EventLabelNeededDuration? = nil)
    }
    
    // MARK: - Output
    enum Output {
        case update(ShopSummary)
    }
    
    // MARK: - Properties
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private(set) var shopId: Int
    private(set) var phonenumber: String = ""
    private(set) var cachedImages: [ShopImage] = []
    private(set) var shopName: String
    let backCategoryName: String?

    private let fetchShopSummaryUseCase: FetchShopSummaryUseCase
    
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private let getUserScreenTimeUseCase: GetUserScreenTimeUseCase
   
    // MARK: - Initializer
    init(fetchShopSummaryUseCase: FetchShopSummaryUseCase,
         logAnalyticsEventUseCase: LogAnalyticsEventUseCase,
         getUserScreenTimeUseCase: GetUserScreenTimeUseCase,
         shopId: Int,
         shopName: String?,
         backCategoryName: String? = nil) {
        self.fetchShopSummaryUseCase = fetchShopSummaryUseCase
        self.shopId = shopId
        self.shopName = shopName ?? ""
        self.backCategoryName = backCategoryName
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
        self.getUserScreenTimeUseCase = getUserScreenTimeUseCase
    }
    
    // MARK: - Transform
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            guard let self else { return }
            switch input {
            case .viewDidLoad:
                self.fetchShopSummary(shopId: shopId)
            case let .logEvent(label, category, value, previousPage, currentPage, durationType, eventLabelNeededDuration):
                self.makeLogAnalyticsEvent(label: label, category: category, value: value, previousPage: previousPage, currentPage: currentPage, screenActionType: durationType, eventLabelNeededDuration: eventLabelNeededDuration)
                
            case let .logEventDirect(label, category, value):
                self.logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
                
            case let .getUserScreenAction(time, screenActionType, eventLabelNeededDuration):
                self.getScreenAction(time: time, screenActionType: screenActionType, eventLabelNeededDuration: eventLabelNeededDuration)
            }
        }
        .store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension ShopSummaryViewModel {
    private func fetchShopSummary(shopId: Int) {
        fetchShopSummaryUseCase.execute(shopId: shopId).sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] shopSummary in
                guard let self else { return }
                self.phonenumber = shopSummary.phone
                self.shopName = shopSummary.name
                self.cachedImages = shopSummary.images
                self.outputSubject.send(.update(shopSummary))
            }
        ).store(in: &subscriptions)
    }
}

extension ShopSummaryViewModel {
    private func makeLogAnalyticsEvent(label: LegacyEventLabelType, category: EventParameter.EventCategory, value: Any, previousPage: String? = nil, currentPage: String? = nil, screenActionType: ScreenActionType? = nil, eventLabelNeededDuration: EventParameter.EventLabelNeededDuration? = nil) {
        if eventLabelNeededDuration != nil {
            var durationTime: Double = 0.0
            switch eventLabelNeededDuration {
            case .shopDetailViewBack, .shopCall:
                durationTime = getUserScreenTimeUseCase.returnUserScreenTime(isEventTime: true)
            default:
                break
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

}

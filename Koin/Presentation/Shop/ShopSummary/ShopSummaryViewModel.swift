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
        case logEvent(EventLabelType, EventParameter.EventCategory, Any, String? = nil, String? = nil, ScreenActionType? = nil, EventParameter.EventLabelNeededDuration? = nil)
        case logEventDirect(EventLabelType, EventParameter.EventCategory, Any)
        case getUserScreenAction(Date, ScreenActionType, EventParameter.EventLabelNeededDuration? = nil)
    }
    
    // MARK: - Output
    enum Output {
        case update1(images: [OrderImage], name: String, rating: Double, reviewCount: Int)
        case update2(delivery: Bool, payBank: Bool, payCard: Bool, maxDeliveryTip: Int = 0, description: String, phone: String)
        case update3(menusGroups: OrderShopMenusGroups, menus: [OrderShopMenus])
    }
    
    // MARK: - Properties
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private(set) var shopId: Int
    private(set) var phonenumber: String = ""
    let shopName: String
    let backCategoryName: String?
    private var cachedThumbnailImages: [OrderImage] = []
    
    private let fetchOrderShopSummaryFromShopUseCase: FetchOrderShopSummaryFromShopUseCase
    private let fetchOrderShopMenusAndGroupsFromShopUseCase: FetchOrderShopMenusAndGroupsFromShopUseCase
    private let fetchShopDataUseCase: FetchShopDataUseCase
    
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private let getUserScreenTimeUseCase: GetUserScreenTimeUseCase
   
    // MARK: - Initializer
    init(fetchOrderShopSummaryFromShopUseCase: DefaultFetchOrderShopSummaryFromShopUseCase,
         fetchOrderShopMenusAndGroupsFromShopUseCase: DefaultFetchOrderShopMenusAndGroupsFromShopUseCase,
         fetchShopDataUseCase: DefaultFetchShopDataUseCase,
         logAnalyticsEventUseCase: LogAnalyticsEventUseCase,
         getUserScreenTimeUseCase: GetUserScreenTimeUseCase,
         shopId: Int,
         shopName: String,
         backCategoryName: String?) {
        self.fetchOrderShopSummaryFromShopUseCase = fetchOrderShopSummaryFromShopUseCase
        self.fetchOrderShopMenusAndGroupsFromShopUseCase = fetchOrderShopMenusAndGroupsFromShopUseCase
        self.fetchShopDataUseCase = fetchShopDataUseCase
        self.shopId = shopId
        self.shopName = shopName
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
                self.fetchShopMenusAndGroups(shopId: shopId)
                self.fetchIsAvailable(shopId: shopId)
                
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
        fetchOrderShopSummaryFromShopUseCase.execute(id: shopId)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] shopSummary in
                guard let self else { return }
                self.cachedThumbnailImages = shopSummary.images
                self.outputSubject.send(.update1(
                    images: shopSummary.images,
                    name: shopSummary.name,
                    rating: shopSummary.ratingAverage,
                    reviewCount: shopSummary.reviewCount))
            })
            .store(in: &subscriptions)
    }
    
    private func fetchShopMenusAndGroups(shopId: Int) {
        fetchOrderShopMenusAndGroupsFromShopUseCase.execute(shopId: shopId)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] (shopMenusCategory, shopMenus) in
                guard let self else { return }
                self.outputSubject.send(.update3(
                    menusGroups: shopMenusCategory,
                    menus: shopMenus))
            })
            .store(in: &subscriptions)
    }
    
    private func fetchIsAvailable(shopId: Int) {
        fetchShopDataUseCase.execute(shopId: shopId)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] in
                guard let self else { return }
                self.phonenumber = $0.phone
                self.outputSubject.send(.update2(
                    delivery: $0.delivery,
                    payBank: $0.payBank,
                    payCard: $0.payCard,
                    maxDeliveryTip: $0.deliveryPrice,
                    description: $0.description,
                    phone: $0.phone))
            })
            .store(in: &subscriptions)
    }
}

extension ShopSummaryViewModel {
    private func makeLogAnalyticsEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any, previousPage: String? = nil, currentPage: String? = nil, screenActionType: ScreenActionType? = nil, eventLabelNeededDuration: EventParameter.EventLabelNeededDuration? = nil) {
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

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
        case viewWillAppear
        case resetCart
        case fetchMenuDetail(orderableShopId: Int, orderableShopMenuId: Int)
        case logEvent(EventLabelType, EventParameter.EventCategory, Any, String? = nil, String? = nil, ScreenActionType? = nil, EventParameter.EventLabelNeededDuration? = nil)
        case logEventDirect(EventLabelType, EventParameter.EventCategory, Any)
        case getUserScreenAction(Date, ScreenActionType, EventParameter.EventLabelNeededDuration? = nil)

    }
    
    // MARK: - Output
    enum Output {
        case updateInfoView(OrderShopSummary, isFromOrder: Bool)
        case updateMenusGroups(OrderShopMenusGroups)
        case updateMenus([OrderShopMenus])
        case updateIsAvailables(delivery: Bool, takeOut: Bool = false, payBank: Bool, payCard: Bool)
        case updateBottomSheet(cartSummary: CartSummary)
        case updateIsAddingMenuAvailable(Bool)
        case updateCartItemsCount(count: Int)
        case updateMenuDetail(OrderMenu)
    }
    
    // MARK: - Properties
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
    // 기본정보 OrderApi
    private let fetchOrderShopSummaryUseCase: FetchOrderShopSummaryUseCase?
    private let fetchOrderShopMenusGroupsUseCase: FetchOrderShopMenusGroupsUseCase?
    private let fetchOrderShopMenusUseCase: FetchOrderShopMenusUseCase?
    
    // 기본정보 ShopApi
    private let fetchOrderShopSummaryFromShopUseCase: FetchOrderShopSummaryFromShopUseCase?
    private let fetchOrderShopMenusAndGroupsFromShopUseCase: FetchOrderShopMenusAndGroupsFromShopUseCase?
    private let fetchShopDataUseCase: FetchShopDataUseCase?
    
    // 장바구니 OrderApi
    private let fetchCartSummaryUseCase: FetchCartSummaryUseCase?
    private let fetchCartUseCase: FetchCartUseCase?
    private let fetchCartItemsCountUseCase: FetchCartItemsCountUseCase?
    private let resetCartUseCase: ResetCartUseCase?
    
    // 주문상세
    private let fetchOrderMenuUseCase: FetchOrderMenuUseCase?
    
    //로깅
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private let getUserScreenTimeUseCase: GetUserScreenTimeUseCase

    
    // Properties
    private(set) var orderableShopId: Int?
    private(set) var shopId: Int?
    private let isFromOrder: Bool
    
    private var cachedShopName: String?
    private var cachedOrderShopSummary: OrderShopSummary?

    // MARK: - Initializer from OrderHome
    init(fetchOrderShopSummaryUseCase: FetchOrderShopSummaryUseCase,
         fetchOrderShopMenusUseCase: FetchOrderShopMenusUseCase,
         fetchOrderShopMenusGroupsUseCase: FetchOrderShopMenusGroupsUseCase,
         fetchCartSummaryUseCase: DefaultFetchCartSummaryUseCase,
         fetchCartUseCase: DefaultFetchCartUseCase,
         fetchCartItemsCountUseCase: DefaultFetchCartItemsCountUseCase,
         resetCartUseCase: DefaultResetCartUseCase,
         fetchOrderMenuUseCase: FetchOrderMenuUseCase,
         logAnalyticsEventUseCase: LogAnalyticsEventUseCase,
         getUserScreenTimeUseCase: GetUserScreenTimeUseCase,
         orderableShopId: Int) {
        // 기본정보 OrderApi
        self.fetchOrderShopSummaryUseCase = fetchOrderShopSummaryUseCase
        self.fetchOrderShopMenusUseCase = fetchOrderShopMenusUseCase
        self.fetchOrderShopMenusGroupsUseCase = fetchOrderShopMenusGroupsUseCase
        // 장바구니 OrderApi
        self.fetchCartSummaryUseCase = fetchCartSummaryUseCase
        self.fetchCartUseCase = fetchCartUseCase
        self.fetchCartItemsCountUseCase = fetchCartItemsCountUseCase
        self.resetCartUseCase = resetCartUseCase
        // 기본정보 ShopApi
        self.fetchOrderShopSummaryFromShopUseCase = nil
        self.fetchOrderShopMenusAndGroupsFromShopUseCase = nil
        self.fetchShopDataUseCase = nil
        // 상세
        self.fetchOrderMenuUseCase = fetchOrderMenuUseCase
        
        // properties
        self.orderableShopId = orderableShopId
        self.isFromOrder = true
        self.shopId = nil
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
        self.getUserScreenTimeUseCase = getUserScreenTimeUseCase
    }
    
    // MARK: - Initializer from Shop
    init(fetchOrderShopSummaryFromShopUseCase: DefaultFetchOrderShopSummaryFromShopUseCase,
         fetchOrderShopMenusAndGroupsFromShopUseCase: DefaultFetchOrderShopMenusAndGroupsFromShopUseCase,
         fetchShopDataUseCase: DefaultFetchShopDataUseCase,
         logAnalyticsEventUseCase: LogAnalyticsEventUseCase,
         getUserScreenTimeUseCase: GetUserScreenTimeUseCase,
         shopId: Int) {
        // 기본정보 ShopApi
        self.fetchOrderShopSummaryFromShopUseCase = fetchOrderShopSummaryFromShopUseCase
        self.fetchOrderShopMenusAndGroupsFromShopUseCase = fetchOrderShopMenusAndGroupsFromShopUseCase
        self.fetchShopDataUseCase = fetchShopDataUseCase
        // 기본정보 OrderApi
        self.fetchOrderShopSummaryUseCase = nil
        self.fetchOrderShopMenusUseCase = nil
        self.fetchOrderShopMenusGroupsUseCase = nil
        // 장바구니 OrderApi
        self.fetchCartSummaryUseCase = nil
        self.fetchCartUseCase = nil
        self.fetchCartItemsCountUseCase = nil
        self.resetCartUseCase = nil
        // 주문상세
        self.fetchOrderMenuUseCase = nil
        // Properties
        self.orderableShopId = nil
        self.shopId = shopId
        self.isFromOrder = false
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
        self.getUserScreenTimeUseCase = getUserScreenTimeUseCase
    }
    
    // MARK: - Transform
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            guard let self else { return }
            switch input {
            case .viewDidLoad:
                if let orderableShopId = self.orderableShopId {
                    self.fetchOrderShopSummaryAndIsAvailable(orderableShopId: orderableShopId)
                    self.fetchOrderShopMenus(orderableShopId: orderableShopId)
                    self.fetchOrderShopMenusGroups(orderableShopId: orderableShopId)
                }
                else if let shopId = shopId {
                    self.fetchShopSummary(shopId: shopId)
                    self.fetchShopMenusAndGroups(shopId: shopId)
                    self.fetchIsAvailable(shopId: shopId)
                }
            case .viewWillAppear:
                guard let orderableShopId = self.orderableShopId else { return }
                self.fetchCartSummary(orderableShopId: orderableShopId)
                self.fetchCart()
                self.fetchCartItemsCount()
            case .resetCart:
                self.resetCart()
            
            case .fetchMenuDetail(let orderableShopId, let orderableShopMenuId):
                self.fetchOrderMenu(orderableShopId: orderableShopId,
                                   orderableShopMenuId: orderableShopMenuId)
                
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
    
    // MARK: - Public Methods
    
    /// 현재 shopId 반환
    func getShopId() -> Int? {
        if isFromOrder {
            let shopId = cachedOrderShopSummary?.shopId
            return shopId
        } else {
            return shopId
        }
    }
    
    // 현재 orderableShopId 반환
    func getOrderableShopId() -> Int? {
        return orderableShopId
    }
    
    /// 현재 상점 이름 반환
    func getShopName() -> String? {
        return cachedShopName
    }
}

extension ShopSummaryViewModel {
    // MARK: - 기본정보 OrderApi
    
    private func fetchOrderShopSummaryAndIsAvailable(orderableShopId: Int) {
        
        fetchOrderShopSummaryUseCase?.execute(orderableShopId: orderableShopId)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("❌ [ViewModel] Fetch failed: \(error)")
                }
            },
                  receiveValue: { [weak self] orderShopSummary in
                guard let self = self else { return }
                
                self.cachedOrderShopSummary = orderShopSummary
                self.cachedShopName = orderShopSummary.name
                
                self.outputSubject.send(.updateInfoView(orderShopSummary, isFromOrder: true))
                self.outputSubject.send(.updateIsAvailables(
                    delivery: orderShopSummary.isDeliveryAvailable,
                    takeOut: orderShopSummary.isTakeoutAvailable,
                    payBank: orderShopSummary.payBank,
                    payCard: orderShopSummary.payCard
                ))
            })
            .store(in: &subscriptions)
    }
    
    private func fetchOrderShopMenus(orderableShopId: Int) {
        fetchOrderShopMenusUseCase?.execute(orderableShopId: orderableShopId)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] orderShopMenus in
                self?.outputSubject.send(.updateMenus(orderShopMenus))
            })
            .store(in: &subscriptions)
    }
    
    private func fetchOrderShopMenusGroups(orderableShopId: Int) {
        fetchOrderShopMenusGroupsUseCase?.execute(orderableShopId: orderableShopId)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] orderShopMenusGroups in
                self?.outputSubject.send(.updateMenusGroups(orderShopMenusGroups))
            })
            .store(in: &subscriptions)
    }

    // MARK: - 기본정보 ShopApi
    
    private func fetchShopSummary(shopId: Int) {
        fetchOrderShopSummaryFromShopUseCase?.execute(id: shopId)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] shopSummary in
                guard let isFromOrder = self?.isFromOrder else { return }
                
                self?.cachedShopName = shopSummary.name
                self?.cachedOrderShopSummary = shopSummary
                
                self?.outputSubject.send(.updateInfoView(shopSummary, isFromOrder: isFromOrder))
            })
            .store(in: &subscriptions)
    }
    
    private func fetchShopMenusAndGroups(shopId: Int) {
        fetchOrderShopMenusAndGroupsFromShopUseCase?.execute(shopId: shopId)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] (shopMenusCategory, shopMenus) in
                self?.outputSubject.send(.updateMenusGroups(shopMenusCategory))
                self?.outputSubject.send(.updateMenus(shopMenus))
            })
            .store(in: &subscriptions)
    }
    
    private func fetchIsAvailable(shopId: Int) {
        fetchShopDataUseCase?.execute(shopId: shopId)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] in
                self?.outputSubject.send(.updateIsAvailables(delivery: $0.delivery, payBank: $0.payBank, payCard: $0.payCard))
            })
            .store(in: &subscriptions)
    }
}

extension ShopSummaryViewModel {
    // MARK: - 장바구니 ShopApi (OrderHome에서 진입시에만 사용)
    
    private func fetchCartSummary(orderableShopId: Int) {
        fetchCartSummaryUseCase?.execute(orderableShopId: orderableShopId)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] in
                self?.outputSubject.send(.updateBottomSheet(cartSummary: $0))
            })
            .store(in: &subscriptions)
    }
    
    private func fetchCartItemsCount() {
        fetchCartItemsCountUseCase?.execute()
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] count in
                self?.outputSubject.send(.updateCartItemsCount(count: count))
            })
            .store(in: &subscriptions)
    }
    
    private func resetCart() {
        resetCartUseCase?.execute()
            .sink(receiveCompletion: { completion in
                if case .failure(let errorResponse) = completion {
                    switch errorResponse.code {
                    case "401": print("로그인 상태가 해제됨")
                    default: print("unknown")
                    }
                }
            }, receiveValue: { [weak self] in
                self?.outputSubject.send(.updateCartItemsCount(count: 0))
            })
            .store(in: &subscriptions)
    }
    
    private func fetchCart() {
         fetchCartUseCase?.execute()
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] (cart, _) in
                let isAddingMenuAvailable = ( self?.orderableShopId == cart.orderableShopId || cart.orderableShopId == nil )
                self?.outputSubject.send(.updateIsAddingMenuAvailable(isAddingMenuAvailable))
            })
            .store(in: &subscriptions)
    }
    
    private func fetchOrderMenu(orderableShopId: Int, orderableShopMenuId: Int) {
        fetchOrderMenuUseCase?
            .execute(orderableShopId: orderableShopId,
                     orderableShopMenuId: orderableShopMenuId)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("호출 실패: \(error)")
                }
            },
                  receiveValue: { [weak self] orderMenu in
                print("호출 성공 \(orderMenu)")
                self?.outputSubject.send(.updateMenuDetail(orderMenu))
            })
            .store(in: &subscriptions)
    }
}

extension ShopSummaryViewModel {
    private func makeLogAnalyticsEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any, previousPage: String? = nil, currentPage: String? = nil, screenActionType: ScreenActionType? = nil, eventLabelNeededDuration: EventParameter.EventLabelNeededDuration? = nil) {
        if eventLabelNeededDuration != nil {
            var durationTime = getUserScreenTimeUseCase.returnUserScreenTime(isEventTime: false)
            
            if eventLabelNeededDuration == .shopDetailViewBack {
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

}

//
//  ShopDetailViewModel.swift
//  koin
//
//  Created by 홍기정 on 9/5/25.
//

import Combine

final class ShopDetailViewModel {
    
    // MARK: - Input
    enum Input {
    case viewDidLoad
    case viewWillAppear
    case resetCart
    case fetchMenuDetail(orderableShopId: Int, orderableShopMenuId: Int)
    }
    
    // MARK: - Output
    enum Output {
    case updateInfoView(OrderShopSummary, isFromOrder: Bool)
    case updateMenusGroups(OrderShopMenusGroups)
    case updateMenus([OrderShopMenus])
    case updateIsAvailables(delivery: Bool, takeOut: Bool?, payBank: Bool, payCard: Bool)
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
    private let fetchOrderShopMenusGroupsFromShopUseCase: FetchOrderShopMenusGroupsFromShopUseCase?
    private let fetchOrderShopMenusFromShopUseCase: FetchOrderShopMenusFromShopUseCase?
    private let fetchShopDataUseCase: FetchShopDataUseCase?
    // 장바구니 OrderApi
    private let fetchCartSummaryUseCase: FetchCartSummaryUseCase?
    private let fetchCartUseCase: FetchCartUseCase?
    private let fetchCartItemsCountUseCase: FetchCartItemsCountUseCase?
    private let resetCartUseCase: ResetCartUseCase?
    //주문상세
    private let fetchOrderMenuUseCase: FetchOrderMenuUseCase?
    
    // Properties
    private(set) var orderableShopId: Int?
    private let shopId: Int?
    private let isFromOrder: Bool
        
    // MARK: - Initializer from OrderHome
    init(fetchOrderShopSummaryUseCase: FetchOrderShopSummaryUseCase,
         fetchOrderShopMenusUseCase: FetchOrderShopMenusUseCase,
         fetchOrderShopMenusGroupsUseCase: FetchOrderShopMenusGroupsUseCase,
         fetchCartSummaryUseCase: DefaultFetchCartSummaryUseCase,
         fetchCartUseCase: DefaultFetchCartUseCase,
         fetchCartItemsCountUseCase: DefaultFetchCartItemsCountUseCase,
         resetCartUseCase: DefaultResetCartUseCase,
         fetchOrderMenuUseCase: FetchOrderMenuUseCase,
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
        // 기본정보 ShoApi
        self.fetchOrderShopSummaryFromShopUseCase = nil
        self.fetchOrderShopMenusGroupsFromShopUseCase = nil
        self.fetchOrderShopMenusFromShopUseCase = nil
        self.fetchShopDataUseCase = nil
        //상세
        self.fetchOrderMenuUseCase = fetchOrderMenuUseCase
        
        // properties
        self.orderableShopId = orderableShopId
        self.isFromOrder = true
        self.shopId = nil
    }
    // MARK: - Initializer from Shop
    init(fetchOrderShopSummaryFromShopUseCase: DefaultFetchOrderShopSummaryFromShopUseCase,
         fetchOrderShopMenusGroupsFromShopUseCase: DefaultFetchOrderShopMenusGroupsFromShopUseCase,
         fetchOrderShopMenusFromShopUseCase: DefaultFetchOrderShopMenusFromShopUseCase,
         fetchShopDataUseCase: DefaultFetchShopDataUseCase,
         
         shopId: Int) {
        // 기본정보 ShopApi
        self.fetchOrderShopSummaryFromShopUseCase = fetchOrderShopSummaryFromShopUseCase
        self.fetchOrderShopMenusGroupsFromShopUseCase = fetchOrderShopMenusGroupsFromShopUseCase
        self.fetchOrderShopMenusFromShopUseCase = fetchOrderShopMenusFromShopUseCase
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
        //주문상세
        self.fetchOrderMenuUseCase = nil
        // Properties
        self.orderableShopId = nil
        self.shopId = shopId
        self.isFromOrder = false
    }
    
    // MARK: Transform
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            guard let self else { return }
            switch input {
            case .viewDidLoad: // 기본정보 호출하기
                if let orderableShopId = self.orderableShopId {
                    self.fetchOrderShopSummaryAndIsAvailable(orderableShopId: orderableShopId)
                    self.fetchOrderShopMenus(orderableShopId: orderableShopId)
                    self.fetchOrderShopMenusGroups(orderableShopId: orderableShopId)
                }
                else if let shopId = shopId {
                    self.fetchShopSummary(shopId: shopId)
                    self.fetchShopmenusCategoryList(shopId: shopId)
                    self.fetchShopMenuList(shopId: shopId)
                    self.fetchIsAvailable(shopId: shopId)
                }
            case .viewWillAppear: // 장바구니 정보 호출하기
                guard let orderableShopId = self.orderableShopId else { return }
                self.fetchCartSummary(orderableShopId: orderableShopId)
                self.fetchCart()
                self.fetchCartItemsCount()
            case .resetCart: // 장바구니 비우기
                self.resetCart()
            
            case .fetchMenuDetail(let orderableShopId, let orderableShopMenuId):
                self.fetchOrderMenu(orderableShopId: orderableShopId,
                                     orderableShopMenuId: orderableShopMenuId)
            }
        }
        .store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension ShopDetailViewModel {
    // MARK: - 기본정보 OrderApi
    private func fetchOrderShopSummaryAndIsAvailable(orderableShopId: Int) {
        fetchOrderShopSummaryUseCase?.execute(orderableShopId: orderableShopId)
            .sink(receiveCompletion: { _ in /* Log 남기기 ? */ },
                  receiveValue: { [weak self] in
                guard let isFromOrder = self?.isFromOrder else { return }
                self?.outputSubject.send(.updateInfoView($0, isFromOrder: isFromOrder))
                self?.outputSubject.send(.updateIsAvailables(delivery: $0.isDeliveryAvailable, takeOut: $0.isTakeoutAvailable, payBank: $0.payBank, payCard: $0.payCard))
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
            .sink(receiveCompletion: { _ in /* Log 남기기 ? */ },
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
                self?.outputSubject.send(.updateInfoView(shopSummary, isFromOrder: isFromOrder))
            })
            .store(in: &subscriptions)
    }
    
    private func fetchShopmenusCategoryList(shopId: Int) {
        fetchOrderShopMenusGroupsFromShopUseCase?.execute(shopId: shopId)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] shopMenusCategory in
                self?.outputSubject.send(.updateMenusGroups(shopMenusCategory))
            })
            .store(in: &subscriptions)
    }
    
    private func fetchShopMenuList(shopId: Int) {
        fetchOrderShopMenusFromShopUseCase?.execute(shopId: shopId)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] shopMenus in
                self?.outputSubject.send(.updateMenus(shopMenus))
            })
            .store(in: &subscriptions)
    }
    
    private func fetchIsAvailable(shopId: Int) {
        fetchShopDataUseCase?.execute(shopId: shopId)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] in
                self?.outputSubject.send(.updateIsAvailables(delivery: $0.delivery, takeOut: nil, payBank: $0.payBank, payCard: $0.payCard))
            })
            .store(in: &subscriptions)
    }
}
extension ShopDetailViewModel {
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
            .sink(receiveCompletion: { comepltion in
                if case .failure(let errorResponse) = comepltion {
                    switch errorResponse.code {
                    case "401": print("로그인 상태가 해제됨") // figma 명세에 없고 & 가능성 낮긴 한데,, 팝업을 띄워야 할까?
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
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] cart in
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

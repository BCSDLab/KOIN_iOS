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
    case didTapCell(menuId: Int)
    case resetCart
    }
    
    // MARK: - Output
    enum Output {
    case updateInfoView(OrderShopSummary, isFromOrder: Bool)
    case updateMenusGroups(OrderShopMenusGroups)
    case updateMenus([OrderShopMenus])
    case updateIsAvailables(delivery: Bool, takeOut: Bool?, payBank: Bool, payCard: Bool)
        
    case updateBottomSheet(cartSummary: CartSummary)
    //case updateCartItemsCount(count: Int)
    }
    
    // MARK: - Properties
    let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
    private let fetchOrderShopSummaryUseCase: FetchOrderShopSummaryUseCase?
    private let fetchOrderShopMenusUseCase: FetchOrderShopMenusUseCase?
    private let fetchOrderShopMenusGroupsUseCase: FetchOrderShopMenusGroupsUseCase?
    
    private let fetchShopSummaryUseCase: FetchShopSummaryUseCase?
    private let fetchShopmenusCategoryListUseCase: DefaultFetchShopmenusCategoryListUseCase?
    private let fetchShopMenuListUseCase: DefaultFetchShopMenuListUseCase?
    private let fetchShopDataUseCase: DefaultFetchShopDataUseCase?
    
    private let fetchCartSummaryUseCase: FetchCartSummaryUseCase?
    
    private let fetchCartItemsCountUseCase: FetchCartItemsCountUseCase?
    private let resetCartUseCase: ResetCartUseCase?
    
    private let orderableShopId: Int?
    private let shopId: Int?
    private let isFromOrder: Bool
    
    // MARK: - Initializer
    init(fetchOrderShopSummaryUseCase: FetchOrderShopSummaryUseCase?,
         fetchOrderShopMenusUseCase: FetchOrderShopMenusUseCase?,
         fetchOrderShopMenusGroupsUseCase: FetchOrderShopMenusGroupsUseCase?,
         fetchCartSummaryUseCase: DefaultFetchCartSummaryUseCase?,
         fetchCartItemsCountUseCase: DefaultFetchCartItemsCountUseCase?,
         resetCartUseCase: DefaultResetCartUseCase?,
         orderableShopId: Int) {
        self.fetchOrderShopSummaryUseCase = fetchOrderShopSummaryUseCase
        self.fetchOrderShopMenusUseCase = fetchOrderShopMenusUseCase
        self.fetchOrderShopMenusGroupsUseCase = fetchOrderShopMenusGroupsUseCase
        self.fetchCartSummaryUseCase = fetchCartSummaryUseCase
        self.fetchCartItemsCountUseCase = fetchCartItemsCountUseCase
        self.resetCartUseCase = resetCartUseCase
        self.orderableShopId = orderableShopId
        self.isFromOrder = true
        self.fetchShopSummaryUseCase = nil
        self.fetchShopmenusCategoryListUseCase = nil
        self.fetchShopMenuListUseCase = nil
        self.fetchShopDataUseCase = nil
        self.shopId = nil
    }
    init(fetchShopSummaryUseCase: FetchShopSummaryUseCase?,
         fetchShopmenusCategoryListUseCase: DefaultFetchShopmenusCategoryListUseCase?,
         fetchShopMenuListUseCase: DefaultFetchShopMenuListUseCase?,
         fetchShopDataUseCase: DefaultFetchShopDataUseCase?,
         shopId: Int?) {
        self.fetchShopSummaryUseCase = fetchShopSummaryUseCase
        self.fetchShopmenusCategoryListUseCase = fetchShopmenusCategoryListUseCase
        self.fetchShopMenuListUseCase = fetchShopMenuListUseCase
        self.fetchShopDataUseCase = fetchShopDataUseCase
        self.shopId = shopId
        self.isFromOrder = false
        self.fetchOrderShopSummaryUseCase = nil
        self.fetchOrderShopMenusUseCase = nil
        self.fetchOrderShopMenusGroupsUseCase = nil
        self.fetchCartSummaryUseCase = nil
        self.fetchCartItemsCountUseCase = nil
        self.resetCartUseCase = nil
        self.orderableShopId = nil
    }
    
    // MARK: Transform
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            guard let self else { return }
            switch input {
            case .viewDidLoad:
                if let orderableShopId = self.orderableShopId {
                    self.fetchOrderShopSummaryAndIsAvailable(orderableShopId: orderableShopId)
                    self.fetchOrderShopMenus(orderableShopId: orderableShopId)
                    self.fetchOrderShopMenusGroups(orderableShopId: orderableShopId)
                    
                    self.fetchCartSummary(orderableShopId: orderableShopId)
                    //self.fetchCartItemsCount()
                }
                else if let shopId = shopId {
                    self.fetchShopSummary(shopId: shopId)
                    self.fetchShopmenusCategoryList(shopId: shopId)
                    self.fetchShopMenuList(shopId: shopId)
                    
                    self.fetchIsAvailable(shopId: shopId)
                }
            case let .didTapCell(menuId):
                
                self.checkShoppingList(menuId: menuId)
            case .resetCart:
                self.resetCart()
            }
        }
        .store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension ShopDetailViewModel {
    // MARK: - Order UseCase
    
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
    
    
    private func fetchCartSummary(orderableShopId: Int) {
        fetchCartSummaryUseCase?.execute(orderableShopId: orderableShopId)
            .sink(receiveCompletion: { completion in
                if case .failure(let failure) = completion {
                    print("fetching Cart Summary Did Fail: \(failure)")
                }
            }, receiveValue: { [weak self] in
                self?.outputSubject.send(.updateBottomSheet(cartSummary: $0))
            })
            .store(in: &subscriptions)
    }
    /*
    private func fetchCartItemsCount() {
        fetchCartItemsCountUseCase?.execute()
            .sink(receiveCompletion: { completion in
                if case .failure(let failure) = completion {
                    print("fetching CartItemsCount Did Fail : \(failure)")
                }
            }, receiveValue: { [weak self] count in
                self?.outputSubject.send(.updateCartItemsCount(count: count))
            })
            .store(in: &subscriptions)
    }
    */
    
    private func resetCart() {
        resetCartUseCase?.execute()
            .sink(receiveCompletion: { completion in
                if case .failure(let failure) = completion {
                    print("ResetCart Did Fail: \(failure)")
                }
            }, receiveValue: { [weak self] in
               // self?.outputSubject.send(.updateCartItemsCount(count: 0))
                print("did reset cart")
            })
            .store(in: &subscriptions)
    }
    
    private func checkShoppingList(menuId: Int) {
        // 바텀시트에서 isAvailable == false 면 팝업
        // TODO: 메뉴 상세 페이지로 이동
        print("menuId: \(menuId)")
    }
}

extension ShopDetailViewModel {
    // MARK: - Shop UseCase
    
    private func fetchShopSummary(shopId: Int) {
        fetchShopSummaryUseCase?.execute(id: shopId)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] shopSummary in
                guard let isFromOrder = self?.isFromOrder else { return }
                self?.outputSubject.send(.updateInfoView(shopSummary, isFromOrder: isFromOrder))
            })
            .store(in: &subscriptions)
    }
    
    private func fetchShopmenusCategoryList(shopId: Int) {
        fetchShopmenusCategoryListUseCase?.execute(shopId: shopId)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] shopMenusCategory in
                self?.outputSubject.send(.updateMenusGroups(shopMenusCategory))
            })
            .store(in: &subscriptions)
    }
    
    private func fetchShopMenuList(shopId: Int) {
        fetchShopMenuListUseCase?.execute(shopId: shopId)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] shopMenus in
                self?.outputSubject.send(.updateMenus(shopMenus))
            })
            .store(in: &subscriptions)
    }
    
    private func fetchIsAvailable(shopId: Int) {
        fetchShopDataUseCase?.execute(shopId: shopId)
            .sink(receiveCompletion: { comepltion in
                if case .failure(let failure) = comepltion {
                    print("fetching isAvailable did fail: \(failure)")
                }
            }, receiveValue: { [weak self] in
                self?.outputSubject.send(.updateIsAvailables(delivery: $0.delivery, takeOut: nil, payBank: $0.payBank, payCard: $0.payCard))
            })
            .store(in: &subscriptions)
    }
}

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
    }
    
    // MARK: - Output
    enum Output {
    case updateInfoView(OrderShopSummary, isFromOrder: Bool)
    case updateMenus([OrderShopMenus])
    case updateMenusGroups(OrderShopMenusGroups)
    case updateIsAvailables(delivery: Bool, takeOut: Bool?, payBank: Bool, payCard: Bool)
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
    
    private let orderableShopId: Int
    private let shopId: Int
    private let isFromOrder: Bool
    
    // MARK: - Initializer
    init(fetchOrderShopSummaryUseCase: FetchOrderShopSummaryUseCase?,
         fetchOrderShopMenusUseCase: FetchOrderShopMenusUseCase?,
         fetchOrderShopMenusGroupsUseCase: FetchOrderShopMenusGroupsUseCase?,
         fetchShopSummaryUseCase: FetchShopSummaryUseCase?,
         fetchShopmenusCategoryListUseCase: DefaultFetchShopmenusCategoryListUseCase?,
         fetchShopMenuListUseCase: DefaultFetchShopMenuListUseCase?,
         fetchShopDataUseCase: DefaultFetchShopDataUseCase?,
         orderableShopId: Int?,
         shopId: Int?,
         isFromOrder: Bool) {
        self.fetchOrderShopSummaryUseCase = fetchOrderShopSummaryUseCase
        self.fetchOrderShopMenusUseCase = fetchOrderShopMenusUseCase
        self.fetchOrderShopMenusGroupsUseCase = fetchOrderShopMenusGroupsUseCase
        self.fetchShopSummaryUseCase = fetchShopSummaryUseCase
        self.fetchShopmenusCategoryListUseCase = fetchShopmenusCategoryListUseCase
        self.fetchShopMenuListUseCase = fetchShopMenuListUseCase
        self.fetchShopDataUseCase = fetchShopDataUseCase
        self.orderableShopId = orderableShopId ?? -1
        self.shopId = shopId ?? -1
        self.isFromOrder = isFromOrder
    }
    
    // MARK: Transform
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case .viewDidLoad:
                guard let self else { return }
                if self.isFromOrder {
                    self.fetchOrderShopSummaryAndIsAvailable(orderableShopId: orderableShopId)
                    self.fetchOrderShopMenus(orderableShopId: orderableShopId)
                    self.fetchOrderShopMenusGroups(orderableShopId: orderableShopId)
                }
                else if !self.isFromOrder {
                    self.fetchShopSummary(shopId: shopId)
                    self.fetchShopmenusCategoryList(shopId: shopId)
                    self.fetchShopMenuList(shopId: shopId)
                    self.fetchIsAvailable(shopId: shopId)
                }
            }
        }
        .store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension ShopDetailViewModel {
    
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
}

extension ShopDetailViewModel {
    
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

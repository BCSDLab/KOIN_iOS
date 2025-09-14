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
    case updateInfoView(OrderShopSummary)
    case updateMenus([OrderShopMenus])
    case updateMenusGroups(OrderShopMenusGroups)
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
         orderableShopId: Int?,
         shopId: Int?,
         isFromOrder: Bool) {
        self.fetchOrderShopSummaryUseCase = fetchOrderShopSummaryUseCase
        self.fetchOrderShopMenusUseCase = fetchOrderShopMenusUseCase
        self.fetchOrderShopMenusGroupsUseCase = fetchOrderShopMenusGroupsUseCase
        self.fetchShopSummaryUseCase = fetchShopSummaryUseCase
        self.fetchShopmenusCategoryListUseCase = fetchShopmenusCategoryListUseCase
        self.fetchShopMenuListUseCase = fetchShopMenuListUseCase
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
                    self.fetchOrderShopSummary(orderableShopId: orderableShopId)
                    self.fetchOrderShopMenus(orderableShopId: orderableShopId)
                    self.fetchOrderShopMenusGroups(orderableShopId: orderableShopId)
                }
                else if !self.isFromOrder {
                    self.fetchShopSummary(shopId: shopId)
                    self.fetchShopmenusCategoryList(shopId: shopId)
                    self.fetchShopMenuList(shopId: shopId)
                }
            }
        }
        .store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension ShopDetailViewModel {
    
    private func fetchOrderShopSummary(orderableShopId: Int) {
        fetchOrderShopSummaryUseCase?.execute(orderableShopId: orderableShopId)
            .sink(receiveCompletion: { _ in /* Log 남기기 ? */ },
                  receiveValue: { [weak self] orderShopSummary in
                self?.outputSubject.send(.updateInfoView(orderShopSummary))
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
                self?.outputSubject.send(.updateInfoView(shopSummary))
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
}

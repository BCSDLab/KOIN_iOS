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
    
    private let orderableShopId: Int
    private let shopId: Int
    private let isFromOrder: Bool
    
    // MARK: - Initializer
    init(fetchOrderShopSummaryUseCase: FetchOrderShopSummaryUseCase?,
         fetchOrderShopMenusUseCase: FetchOrderShopMenusUseCase?,
         fetchOrderShopMenusGroupsUseCase: FetchOrderShopMenusGroupsUseCase?,
         fetchShopSummaryUseCase: FetchShopSummaryUseCase?,
         orderableShopId: Int?,
         shopId: Int?,
         isFromOrder: Bool) {
        self.fetchOrderShopSummaryUseCase = fetchOrderShopSummaryUseCase
        self.fetchOrderShopMenusUseCase = fetchOrderShopMenusUseCase
        self.fetchOrderShopMenusGroupsUseCase = fetchOrderShopMenusGroupsUseCase
        self.fetchShopSummaryUseCase = fetchShopSummaryUseCase
        self.orderableShopId = orderableShopId ?? -1
        self.shopId = shopId ?? -1
        self.isFromOrder = isFromOrder
    }
    
    // MARK: Transform
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case .viewDidLoad:
                // useCase로 데이터를 호출하고, viewController에 돌려주는 로직
                guard let self else { return }
                if self.isFromOrder {
                    self.fetchOrderShopSummary(orderableShopId: orderableShopId)
                    self.fetchOrderShopMenus(orderableShopId: orderableShopId)
                    self.fetchOrderShopMenusGroups(orderableShopId: orderableShopId)
                }
                else if !self.isFromOrder {
                    print("isFromShop")
                    print("shopId: \(self.shopId)")
                    self.fetchShopSummary(shopId: shopId)
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
            .sink(receiveCompletion: {
                /* Log 남기기 ? */
                if case .failure(let error) = $0 {
                    print("fetching menus did fail : \(error)")
                }
            },
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
            .sink(receiveCompletion: { completion in
                if case .failure(let failure) = completion {
                    print("fetching shopSummary did fail : \(failure)")
                }
            },
                  receiveValue: { [weak self] shopSummary in
                self?.outputSubject.send(.updateInfoView(shopSummary))
            })
            .store(in: &subscriptions)
    }
}

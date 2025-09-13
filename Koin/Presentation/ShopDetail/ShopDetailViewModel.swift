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
    case viewDidLoad(shopId: Int)
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
    private let fetchOrderShopSummaryUseCase: FetchOrderShopSummaryUseCase
    private let fetchOrderShopMenusUseCase: FetchOrderShopMenusUseCase
    private let fetchOrderShopMenusGroupsUseCase: FetchOrderShopMenusGroupsUseCase
    
    // MARK: - Initializer
    init(fetchOrderShopSummaryUseCase: FetchOrderShopSummaryUseCase,
         fetchOrderShopMenusUseCase: FetchOrderShopMenusUseCase,
         fetchOrderShopMenusGroupsUseCase: FetchOrderShopMenusGroupsUseCase) {
        self.fetchOrderShopSummaryUseCase = fetchOrderShopSummaryUseCase
        self.fetchOrderShopMenusUseCase = fetchOrderShopMenusUseCase
        self.fetchOrderShopMenusGroupsUseCase = fetchOrderShopMenusGroupsUseCase
    }
    
    // MARK: Transform
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case let .viewDidLoad(shopId):
                // useCase로 데이터를 호출하고, viewController에 돌려주는 로직
                self?.fetchOrderShopSummary(shopId)
                self?.fetchOrderShopMenus(shopId)
                self?.fetchOrderShopMenusGroups(shopId)
            }
        }
        .store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension ShopDetailViewModel {
    
    private func fetchOrderShopSummary(_ shopId: Int) {
        fetchOrderShopSummaryUseCase.execute(shopId: shopId)
            .sink(receiveCompletion: { _ in /* Log 남기기 ? */ },
                  receiveValue: { [weak self] orderShopSummary in
                self?.outputSubject.send(.updateInfoView(orderShopSummary))
            })
            .store(in: &subscriptions)
    }
    private func fetchOrderShopMenus(_ shopId: Int) {
        fetchOrderShopMenusUseCase.execute(shopId: shopId)
            .sink(receiveCompletion: { _ in /* Log 남기기 ? */ },
                  receiveValue: { [weak self] orderShopMenus in
                self?.outputSubject.send(.updateMenus(orderShopMenus))
            })
            .store(in: &subscriptions)
    }
    private func fetchOrderShopMenusGroups(_ shopId: Int) {
        fetchOrderShopMenusGroupsUseCase.execute(shopId: shopId)
            .sink(receiveCompletion: { _ in /* Log 남기기 ? */ },
                  receiveValue: { [weak self] orderShopMenusGroups in
                self?.outputSubject.send(.updateMenusGroups(orderShopMenusGroups))
            })
            .store(in: &subscriptions)
    }
}

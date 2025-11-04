//
//  ShopDetailViewModel.swift
//  koin
//
//  Created by 홍기정 on 10/13/25.
//

import Foundation
import Combine

final class ShopDetailViewModel {
    
    enum Input {
        case viewDidLoad
    }
    
    enum Output {
        case update(shopDetail: OrderShopDetail)
    }
    
    // MARK: - Properties
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let fetchOrderShopDetailUseCase: FetchOrderShopDetailUseCase?
    private let fetchOrderShopDetailFromShopUseCase: FetchOrderShopDetailFromShopUseCase?
    private let orderableShopId: Int?
    private let shopId: Int?
    var isFromOrder: Bool {
        return self.orderableShopId != nil
    }
    
    // MARK: - Initializer
    init(fetchOrderShopDetailUseCase: DefaultFetchOrderShopDetailUseCase,
         orderableShopId: Int) {
        self.fetchOrderShopDetailUseCase = fetchOrderShopDetailUseCase
        self.orderableShopId = orderableShopId
        self.fetchOrderShopDetailFromShopUseCase = nil
        self.shopId = nil
    }
    init(fetchOrderShopDetailFromShopUseCase: DefaultFetchOrderShopDetailFromShopUseCase,
         shopId: Int) {
        self.fetchOrderShopDetailFromShopUseCase = fetchOrderShopDetailFromShopUseCase
        self.shopId = shopId
        self.fetchOrderShopDetailUseCase = nil
        self.orderableShopId = nil
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case .viewDidLoad:
                self?.fetchShopDetail()
            }
        }
        .store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension ShopDetailViewModel {
    
    private func fetchShopDetail() {
        if let orderableShopId, let fetchOrderShopDetailUseCase {
            fetchOrderShopDetailUseCase.execute(orderableShopId: orderableShopId)
                .sink(receiveCompletion: { comepltion in
                    if case .failure(let failure) = comepltion {
                        print("fetchOrdershopDetail Failed: \(failure)")
                    }
                }, receiveValue: { [weak self] orderShopDetail in
                    print("fetchOrderShopDetail Succeded")
                    self?.outputSubject.send(.update(shopDetail: orderShopDetail))
                })
                .store(in: &subscriptions)
        }
        else if let shopId, let fetchOrderShopDetailFromShopUseCase {
            fetchOrderShopDetailFromShopUseCase.execute(shopId: shopId)
                .sink(receiveCompletion: { completion in
                    if case .failure(let failure) = completion {
                        print("fetchOrdershopDetailFromShop Failed: \(failure)")
                    }
                }, receiveValue: { [weak self] orderShopDetail in
                    print("fetchOrderShopDetailFromShop Succeded")
                    self?.outputSubject.send(.update(shopDetail: orderShopDetail))
                })
                .store(in: &subscriptions)
        }
    }
}

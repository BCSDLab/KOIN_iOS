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
    private let fetchOrderShopDetailFromShopUseCase: FetchOrderShopDetailFromShopUseCase
    private let shopId: Int
    
    // MARK: - Initializer
    init(fetchOrderShopDetailFromShopUseCase: DefaultFetchOrderShopDetailFromShopUseCase,
         shopId: Int) {
        self.fetchOrderShopDetailFromShopUseCase = fetchOrderShopDetailFromShopUseCase
        self.shopId = shopId
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
        fetchOrderShopDetailFromShopUseCase.execute(shopId: shopId)
            .sink(receiveCompletion: { completion in
                if case .failure(let failure) = completion {
                    print("fetchOrdershopDetailFromShop Failed: \(failure)")
                }
            }, receiveValue: { [weak self] orderShopDetail in
                self?.outputSubject.send(.update(shopDetail: orderShopDetail))
            })
            .store(in: &subscriptions)
    }
}

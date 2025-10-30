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
    private let fetchOrderShopDetailUseCase: FetchOrderShopDetailUseCase
    private let orderableShopId: Int?
    
    // MARK: - Initializer
    init(fetchOrderShopDetailUseCase: DefaultFetchOrderShopDetailUseCase, orderableShopId: Int?) {
        self.fetchOrderShopDetailUseCase = fetchOrderShopDetailUseCase
        self.orderableShopId = orderableShopId
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
        guard let orderableShopId = self.orderableShopId else {
            print("guard let failed")
            return
        }
        print("orderableShopId : \(orderableShopId)")
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
}

//
//  FetchCartDeliveryUseCase.swift
//  koin
//
//  Created by 홍기정 on 9/16/25.
//

import Combine

protocol FetchCartDeliveryUseCase {
    func execute() -> AnyPublisher<(Cart, isFromDelivery: Bool), Error>
}

final class DefaultFetchCartDeliveryUseCase: FetchCartDeliveryUseCase {
    
    private let repository: OrderShopRepository
    
    init(repository: OrderShopRepository) {
        self.repository = repository
    }
    
    func execute() -> AnyPublisher<(Cart, isFromDelivery: Bool), Error> {
        repository.fetchCart(parameter: .delivery)
            .map {
                return ($0, isFromDelivery: true)
            }
            .eraseToAnyPublisher()
    }
}


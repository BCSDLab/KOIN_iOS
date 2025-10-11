//
//  FetchCartDeliveryUseCase.swift
//  koin
//
//  Created by 홍기정 on 9/16/25.
//

import Combine

protocol FetchCartDeliveryUseCase {
    func execute() -> AnyPublisher<Cart, Error>
}

final class DefaultFetchCartDeliveryUseCase: FetchCartDeliveryUseCase {
    
    let repository: OrderShopRepository
    
    init(repository: OrderShopRepository) {
        self.repository = repository
    }
    
    func execute() -> AnyPublisher<Cart, Error> {
        repository.fetchCart(parameter: .delivery)
            .eraseToAnyPublisher()
    }
}


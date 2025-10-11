//
//  FetchCartTakeOutUseCase.swift
//  koin
//
//  Created by 홍기정 on 9/16/25.
//

import Combine

protocol FetchCartTakeOutUseCase {
    func execute() -> AnyPublisher<(Cart, isFromDelivery: Bool), Error>
}

final class DefaultFetchCartTakeOutUseCase: FetchCartTakeOutUseCase {
    
    let repository: OrderShopRepository
    
    init(repository: OrderShopRepository) {
        self.repository = repository
    }
    
    func execute() -> AnyPublisher<(Cart, isFromDelivery: Bool), Error> {
        repository.fetchCart(parameter: .takeOut)
            .eraseToAnyPublisher()
    }
}


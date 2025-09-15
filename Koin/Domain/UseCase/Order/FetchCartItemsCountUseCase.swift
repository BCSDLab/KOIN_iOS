//
//  FetchCartItemsCountUseCase.swift
//  koin
//
//  Created by 홍기정 on 9/15/25.
//

import Combine

protocol FetchCartItemsCountUseCase {
    func execute() -> AnyPublisher<Int, Error>
}

class DefaultFetchCartItemsCountUseCase: FetchCartItemsCountUseCase {
    
    let repository: OrderShopRepository
    
    init(repository: OrderShopRepository) {
        self.repository = repository
    }
    
    func execute() -> AnyPublisher<Int, Error> {
        repository.fetchCartItemsCount()
            .map { $0.totalQuantity }
            .eraseToAnyPublisher()
    }
}

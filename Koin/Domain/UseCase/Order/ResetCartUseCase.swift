//
//  ResetCartUseCase.swift
//  koin
//
//  Created by 홍기정 on 9/16/25.
//

import Combine

protocol ResetCartUseCase {
    func execute() -> AnyPublisher<Void, Error>
}

class DefaultResetCartUseCase: ResetCartUseCase {
    
    let repository: OrderShopRepository
    
    init(repository: OrderShopRepository) {
        self.repository = repository
    }
    
    func execute() -> AnyPublisher<Void, Error> {
        repository.resetCart()
            .eraseToAnyPublisher()
    }
}

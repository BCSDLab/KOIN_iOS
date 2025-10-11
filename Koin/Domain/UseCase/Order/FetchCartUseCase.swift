//
//  FetchCartUseCase.swift
//  koin
//
//  Created by 홍기정 on 9/16/25.
//

import Combine

protocol FetchCartUseCase {
    func execute() -> AnyPublisher<(Cart, isFromDelivery: Bool), Error>
}

final class DefaultFetchCartUseCase: FetchCartUseCase {
    
    let repository: OrderShopRepository
    
    init(repository: OrderShopRepository) {
        self.repository = repository
    }
    
    func execute() -> AnyPublisher<(Cart, isFromDelivery: Bool), Error> {
        repository.fetchCart(parameter: .delivery)
            .catch { [weak self] error -> AnyPublisher<(Cart, isFromDelivery: Bool), Error> in
                guard let self = self else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
                switch error.asAFError?.responseCode {
                case 400:
                    return repository.fetchCart(parameter: .takeOut).eraseToAnyPublisher()
                default:
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
}


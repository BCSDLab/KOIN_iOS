//
//  FetchCartUseCase.swift
//  koin
//
//  Created by 홍기정 on 9/16/25.
//

import Combine
import Alamofire

protocol FetchCartUseCase {
    func execute() -> AnyPublisher<Cart, Error>
}

class DefaultFetchCartUseCase: FetchCartUseCase {
    
    let repository: OrderShopRepository
    
    init(repository: OrderShopRepository) {
        self.repository = repository
    }
    
    var temp: Set<AnyCancellable> = []
    func execute() -> AnyPublisher<Cart, Error> {
        repository.fetchCartDelivery()
            .catch { [weak self] error -> AnyPublisher<Cart, Error> in
                guard let self = self else {
                    return Fail(error: AFError.explicitlyCancelled).eraseToAnyPublisher()
                }
                switch error.asAFError?.responseCode {
                case 400:
                    return self.repository.fetchCartTakeOut()
                        .eraseToAnyPublisher()
                default:
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
}


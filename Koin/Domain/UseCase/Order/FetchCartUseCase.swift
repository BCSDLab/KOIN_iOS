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
    
    enum parameter: String {
        case delivery = "DELIVERY"
        case takeOut = "TAKE_OUT"
    }
    func execute() -> AnyPublisher<Cart, Error> {
        repository.fetchCart(parameter: parameter.delivery.rawValue)
            .catch { [weak self] error -> AnyPublisher<Cart, Error> in
                guard let self = self else {
                    return Fail(error: AFError.explicitlyCancelled).eraseToAnyPublisher()
                }
                switch error.asAFError?.responseCode {
                case 400:
                    return self.repository.fetchCart(parameter: parameter.takeOut.rawValue)
                        .eraseToAnyPublisher()
                default:
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
}


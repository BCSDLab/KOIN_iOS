//
//  FetchOrderShopMenusUseCase.swift
//  koin
//
//  Created by 홍기정 on 9/12/25.
//

import Foundation
import Combine

protocol FetchOrderShopMenusUseCase {
    func execute() -> AnyPublisher<[OrderShopMenus], Error>
}

class DefaultFetchOrderShopMenusUseCase: FetchOrderShopMenusUseCase {
    func execute() -> AnyPublisher<[OrderShopMenus], Error> {
        return Just(OrderShopMenus.dummy())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

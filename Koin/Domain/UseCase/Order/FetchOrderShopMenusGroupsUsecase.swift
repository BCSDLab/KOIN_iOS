//
//  FetchOrderShopMenusGroupsUseCase.swift
//  koin
//
//  Created by 홍기정 on 9/12/25.
//

import Foundation
import Combine

protocol FetchOrderShopMenusGroupsUseCase {
    func execute() -> AnyPublisher<OrderShopMenusGroups, Error>
}

class DefaultFetchOrderShopMenusGroupsUseCase: FetchOrderShopMenusGroupsUseCase {
    func execute() -> AnyPublisher<OrderShopMenusGroups, any Error> {
        return Just(OrderShopMenusGroups.dummy())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

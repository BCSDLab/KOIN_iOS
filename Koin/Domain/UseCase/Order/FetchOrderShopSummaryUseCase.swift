//
//  FetchOrderShopSummaryUseCase.swift
//  koin
//
//  Created by 홍기정 on 9/12/25.
//

import Foundation
import Combine

protocol FetchOrderShopSummaryUseCase {
    func execute() -> AnyPublisher<OrderShopSummary, Error>
}

class DefaultFetchOrderShopSummaryUseCase: FetchOrderShopSummaryUseCase {
    func execute() -> AnyPublisher<OrderShopSummary, Error> {
        return Just(OrderShopSummary.dummy())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

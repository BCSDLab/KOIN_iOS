//
//  FetchOrderHistoryUseCase.swift
//  koin
//
//  Created by 김성민 on 9/10/25.
//

import Foundation
import Combine

protocol FetchOrderHistoryUseCase {
    func execute(query: OrderHistoryQuery) -> AnyPublisher<OrdersPage, Error>
}

extension FetchOrderHistoryUseCase {
    func execute() -> AnyPublisher<OrdersPage, Error> {
        execute(query: OrderHistoryQuery())
    }

//    func executeFlat(query: OrderHistoryQuery) -> AnyPublisher<[Order], Error> {
//        execute(query: query).map(\.orders).eraseToAnyPublisher()
//    }
}

final class DefaultFetchOrderHistoryUseCase: FetchOrderHistoryUseCase {
    private let repository: OrderHistoryRepository
    init(repository: OrderHistoryRepository) { self.repository = repository }

    func execute(query: OrderHistoryQuery) -> AnyPublisher<OrdersPage, Error> {
        repository.fetchOrderHistory(query: query)
    }
}

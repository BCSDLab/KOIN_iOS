//
//  FetchOrderHistoryUseCase.swift
//  koin
//
//  Created by 김성민 on 9/10/25.
//

import Foundation
import Combine

protocol FetchOrderHistoryUseCase {
    func execute(query: OrderHistoryQuery) -> AnyPublisher<[Order], Error>
}

extension FetchOrderHistoryUseCase {
    func execute() -> AnyPublisher<[Order], Error> {
        execute(query: OrderHistoryQuery())
    }
}

final class DefaultFetchOrderHistoryUseCase: FetchOrderHistoryUseCase {
    private let repository: OrderHistoryRepository
    init(repository: OrderHistoryRepository) { self.repository = repository }

    func execute(query: OrderHistoryQuery) -> AnyPublisher<[Order], Error> {
        repository.fetchOrderHistory(query: query)
    }
}

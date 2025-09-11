//
//  OrderHistoryRepository.swift
//  koin
//
//  Created by 김성민 on 9/10/25.
//

import Foundation
import Combine

protocol OrderHistoryRepository {
    func fetchOrderHistory(query: OrderHistoryQuery) -> AnyPublisher<OrdersPage, Error>
}

extension OrderHistoryRepository {
    func fetchOrderHistory() -> AnyPublisher<OrdersPage, Error> {
        fetchOrderHistory(query: OrderHistoryQuery())
    }
}

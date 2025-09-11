//
//  DefaultOrderHistoryRepository.swift
//  koin
//
//  Created by 김성민 on 9/10/25.
//

import Foundation
import Combine

final class DefaultOrderHistoryRepository: OrderHistoryRepository {
    private let service: OrderService

    init(service: OrderService) {
        self.service = service
    }

    func fetchOrderHistory(query: OrderHistoryQuery) -> AnyPublisher<OrdersPage, Error> {
        service.fetchOrderHistory(query: query)
    }
}


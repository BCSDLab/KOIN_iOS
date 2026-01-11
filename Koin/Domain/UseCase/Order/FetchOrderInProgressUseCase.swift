//
//  FetchOrderInProgressUseCase.swift
//  koin
//
//  Created by 이은지 on 9/8/25.
//

import Combine

protocol FetchOrderInProgressUseCase {
    func execute() -> AnyPublisher<[OrderInProgress], Error>
}

final class DefaultFetchOrderInProgressUseCase: FetchOrderInProgressUseCase {
    
    private let orderShopRepository: OrderShopRepository
    
    init(orderShopRepository: OrderShopRepository) {
        self.orderShopRepository = orderShopRepository
    }
    
    func execute() -> AnyPublisher<[OrderInProgress], Error> {
        orderShopRepository.fetchOrderInProgress()
    }
}

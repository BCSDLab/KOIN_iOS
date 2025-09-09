//
//  FetchOrderTrackingUseCase.swift
//  koin
//
//  Created by 이은지 on 9/8/25.
//

import Combine

protocol FetchOrderTrackingUseCase {
    func execute() -> AnyPublisher<OrderTrackingInfo, Error>
}
final class DefaultFetchOrderTrackingUseCase: FetchOrderTrackingUseCase {
    
    private let orderShopRepository: OrderShopRepository
    
    init(orderShopRepository: OrderShopRepository) {
        self.orderShopRepository = orderShopRepository
    }
    
    func execute() -> AnyPublisher<OrderTrackingInfo, Error> {
        return orderShopRepository.fetchOrderTrackingInfo()
    }
}

//
//  FetchOrderShopListUseCase.swift
//  koin
//
//  Created by 이은지 on 7/6/25.
//

import Combine

protocol FetchOrderShopListUseCase {
    func execute(requestModel: FetchOrderShopListRequest) -> AnyPublisher<[OrderShop], Error>
}

final class DefaultFetchOrderShopListUseCase: FetchOrderShopListUseCase {
    
    private let orderShopRepository: OrderShopRepository
    
    init(orderShopRepository: OrderShopRepository) {
        self.orderShopRepository = orderShopRepository
    }
    
    func execute(requestModel: FetchOrderShopListRequest) -> AnyPublisher<[OrderShop], Error> {
        return orderShopRepository.fetchOrderShopList(requestModel: requestModel)
            .eraseToAnyPublisher()
    }
}

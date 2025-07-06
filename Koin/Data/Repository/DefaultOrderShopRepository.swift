//
//  DefaultOrderShopRepository.swift
//  koin
//
//  Created by 이은지 on 7/7/25.
//

import Combine
import Foundation

final class DefaultOrderShopRepository: OrderShopRepository{
    
    private let service: OrderService
    
    init(service: OrderService) {
        self.service = service
    }

    func fetchOrderShopList(requestModel: FetchOrderShopListRequest) -> AnyPublisher<[OrderShop], any Error> {
        print("OrderShopRepository: fetchOrderShopList called")
        return service.fetchOrderShopList(requestModel: requestModel)
    }
}

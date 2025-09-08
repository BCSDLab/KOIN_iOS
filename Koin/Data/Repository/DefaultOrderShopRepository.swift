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
    
    func fetchOrderShopList(requestModel: FetchOrderShopListRequest) -> AnyPublisher<[OrderShop], Error> {
        return service.fetchOrderShopList(requestModel: requestModel)
            .map { dtos in
                dtos.map(OrderShop.init)
            }
            .eraseToAnyPublisher()
    }
    
    func fetchOrderEventShop() -> AnyPublisher<[OrderShopEvent], Error> {
        service.fetchOrderEventShop()
            .map { $0.map(OrderShopEvent.init) }
            .eraseToAnyPublisher()
    }
    
    func searchRelatedQuery(text: String) -> AnyPublisher<RelatedKeywordsDTO, Error> {
        return service.searchRelatedShops(text: text)
    }
    
    // TODO: - 임시
    func fetchOrderTrackingInfo() -> AnyPublisher<OrderTrackingInfo, Error> {
        return service.fetchOrderTrackingInfo()
            .tryMap { dto in
                guard let entity = OrderTrackingInfo(from: dto) else {
                    throw MappingError.invalidData
                }
                return entity
            }
            .eraseToAnyPublisher()
    }
}

// TODO: - 임시
enum MappingError: Error {
    case invalidData
}

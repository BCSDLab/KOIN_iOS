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
    
    // MARK: - 여기 아래로 새로 추가
    func fetchOrderShopMenus(orderableShopId: Int) -> AnyPublisher<[OrderShopMenus], Error> {
        service.fetchOrderShopMenus(orderableShopId: orderableShopId)
            .map { dto in
                dto.map { OrderShopMenus(from: $0) }
            }
            .eraseToAnyPublisher()
    }
    
    func fetchOrderShopMenusGroups(orderableShopId: Int) -> AnyPublisher<OrderShopMenusGroups, Error> {
        service.fetchOrderShopMenusGroups(orderableShopId: orderableShopId)
            .map { dto in
                OrderShopMenusGroups(from: dto)
            }
            .eraseToAnyPublisher()
    }
    
    func fetchOrderShopSummary(orderableShopId: Int) -> AnyPublisher<OrderShopSummary, Error> {
        service.fetchOrderShopSummary(orderableShopId: orderableShopId)
            .map { dto in
                return OrderShopSummary(from: dto)
            }
            .eraseToAnyPublisher()
    }
}

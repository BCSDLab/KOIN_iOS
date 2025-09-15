//
//  OrderService.swift
//  koin
//
//  Created by 이은지 on 7/7/25.
//

import Alamofire
import Combine

protocol OrderService {
    func fetchOrderShopList(requestModel: FetchOrderShopListRequest) -> AnyPublisher<[OrderShopDTO], Error>
    func fetchOrderEventShop() -> AnyPublisher<[OrderShopEventDTO], Error>
    func searchRelatedShops(text: String) -> AnyPublisher<RelatedKeywordsDTO, Error>
    func fetchOrderShopMenus(orderableShopId: Int) -> AnyPublisher<[OrderShopMenusDTO], Error>
    func fetchOrderShopMenusGroups(orderableShopId: Int) -> AnyPublisher<OrderShopMenusGroupsDTO, Error>
    func fetchOrderShopSummary(orderableShopId: Int) -> AnyPublisher<OrderShopSummaryDTO, Error>
    func fetchOrderInProgress() -> AnyPublisher<[OrderInProgress], Error>
    func fetchCartSummary(orderableShopId: Int) -> AnyPublisher<CartSummaryDTO, Error>
    func fetchCartItemsCount() -> AnyPublisher<CartItemsCountDTO, Error>
    func resetCart() -> AnyPublisher<Void, Error>
}

final class DefaultOrderService: OrderService {
    
    func fetchOrderShopList(requestModel: FetchOrderShopListRequest) -> AnyPublisher<[OrderShopDTO], Error> {
        return request(.fetchOrderShopList(requestModel))
            .eraseToAnyPublisher()
    }
    
    func fetchOrderEventShop() -> AnyPublisher<[OrderShopEventDTO], Error> {
        return request(.fetchOrderEventShop)
            .map { (response: OrderShopEventListResponseDTO) in
                response.shopEvents
            }
            .eraseToAnyPublisher()
    }
    
    func searchRelatedShops(text: String) -> AnyPublisher<RelatedKeywordsDTO, Error> {
        return request(.searchShop(text))
    }
    
    func fetchOrderShopMenus(orderableShopId: Int) -> AnyPublisher<[OrderShopMenusDTO], Error> {
        return request(.fetchOrderShopMenus(orderableShopId: orderableShopId))
            .eraseToAnyPublisher()
    }
    func fetchOrderShopMenusGroups(orderableShopId: Int) -> AnyPublisher<OrderShopMenusGroupsDTO, Error> {
        return request(.fetchOrderShopMenusGroups(orderableShopId: orderableShopId))
            .eraseToAnyPublisher()
    }
    func fetchOrderShopSummary(orderableShopId: Int) -> AnyPublisher<OrderShopSummaryDTO, Error> {
        return request(.fetchOrderShopSummary(orderableShopId: orderableShopId))
            .eraseToAnyPublisher()
    }
    func fetchOrderInProgress() -> AnyPublisher<[OrderInProgress], Error> {
        request(.fetchOrderInProgress)
            .map { (dtos: [OrderInProgressDTO]) in
                dtos.map { $0.toEntity() }
            }
            .eraseToAnyPublisher()
    }
    func fetchCartSummary(orderableShopId: Int) -> AnyPublisher<CartSummaryDTO, Error> {
        request(.fetchCartSummary(orderableShopId: orderableShopId))
            .eraseToAnyPublisher()
    }
    func fetchCartItemsCount() -> AnyPublisher<CartItemsCountDTO, Error> {
        request(.fetchCartItemsCount)
            .eraseToAnyPublisher()
    }
    func resetCart() -> AnyPublisher<Void, Error> {
        (request(.resetCart) as AnyPublisher<String, Error>)
            .map { _ in
                return }
            .eraseToAnyPublisher( )
    }

    private func request<T: Decodable>(_ api: OrderAPI) -> AnyPublisher<T, Error> {
        return AF.request(api)
            .validate(statusCode: 200..<300)
            .publishData()
            .tryMap { response in
                let decoder = JSONDecoder()
                switch response.result {
                case .success(let data):
                    do {
                        return try decoder.decode(T.self, from: data)
                    } catch {
                        throw error
                    }
                case .failure(let afError):
                    throw afError
                }
            }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}

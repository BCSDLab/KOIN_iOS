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
    func fetchOrderInProgress() -> AnyPublisher<[OrderInProgress], Error>
    
    func fetchOrderHistory(query: OrderHistoryQuery) -> AnyPublisher<OrdersPage, Error>

}

final class DefaultOrderService: OrderService {
 
    
    func fetchOrderShopList(requestModel: FetchOrderShopListRequest) -> AnyPublisher<[OrderShopDTO], Error> {
        return request(.fetchOrderShopList(requestModel))
            .eraseToAnyPublisher()
    }
    
    func fetchOrderEventShop() -> AnyPublisher<[OrderShopEventDTO], Error> {
        request(.fetchOrderEventShop)
            .map { (response: OrderShopEventListResponseDTO) in
                response.shopEvents
            }
            .eraseToAnyPublisher()
    }
    
    func searchRelatedShops(text: String) -> AnyPublisher<RelatedKeywordsDTO, Error> {
        return request(.searchShop(text))
    }
    
    func fetchOrderInProgress() -> AnyPublisher<[OrderInProgress], Error> {
        request(.fetchOrderInProgress)
            .map { (dtos: [OrderInProgressDTO]) in
                dtos.map { $0.toEntity() }
            }
            .eraseToAnyPublisher()
    }
    
    func fetchOrderHistory(query: OrderHistoryQuery) -> AnyPublisher<OrdersPage, Error> {
        let dto = OrderHistoryQueryDTO(query)
        return request(.fetchOrder(query: dto))
            .map { (res: OrdersHistoryResponseDTO) in res.toPageEntity() }
            .eraseToAnyPublisher()
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

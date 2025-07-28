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
    func searchRelatedShops(text: String) -> AnyPublisher<RelatedKeywordsDTO, Error>
}

final class DefaultOrderService: OrderService {
    
    func fetchOrderShopList(requestModel: FetchOrderShopListRequest) -> AnyPublisher<[OrderShopDTO], Error> {
        return request(.fetchOrderShopList(requestModel))
    }
    
    func searchRelatedShops(text: String) -> AnyPublisher<RelatedKeywordsDTO, Error> {
        return request(.searchShop(text))
    }

    private func request<T: Decodable>(_ api: OrderAPI) -> AnyPublisher<T, Error> {
        return AF.request(api)
            .publishDecodable(type: T.self)
            .value()
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}

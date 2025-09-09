//
//  OrderShopRepository.swift
//  koin
//
//  Created by 이은지 on 7/6/25.
//

import Foundation
import Combine

protocol OrderShopRepository {
    func fetchOrderShopList(requestModel: FetchOrderShopListRequest) -> AnyPublisher<[OrderShop], Error>
    func fetchOrderEventShop() -> AnyPublisher<[OrderShopEvent], Error>
    func searchRelatedQuery(text: String) -> AnyPublisher<RelatedKeywordsDTO, Error>
    func fetchOrderTrackingInfo() -> AnyPublisher<OrderInProgress, Error>
}

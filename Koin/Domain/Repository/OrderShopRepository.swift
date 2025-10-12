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
    func searchRelatedQuery(text: String) -> AnyPublisher<RelatedKeywordsDto, Error>
    func fetchOrderShopMenus(orderableShopId: Int) -> AnyPublisher<[OrderShopMenus], Error>
    func fetchOrderShopMenusGroups(orderableShopId: Int) -> AnyPublisher<OrderShopMenusGroups, Error>
    func fetchOrderShopSummary(orderableShopId: Int) -> AnyPublisher<OrderShopSummary, Error>
    func fetchOrderInProgress() -> AnyPublisher<[OrderInProgress], Error>
    func fetchCartSummary(orderableShopId: Int) -> AnyPublisher<CartSummary, Error>
    func fetchCartItemsCount() -> AnyPublisher<CartItemsCount, Error>
    func fetchCart(parameter: FetchCartParameter) -> AnyPublisher<(Cart, isFromDelivery: Bool), Error>
    func resetCart() -> AnyPublisher<Void, ErrorResponse>
    func deleteCartMenuItem(cartMenuItemId: Int) -> AnyPublisher<Void, ErrorResponse>
}

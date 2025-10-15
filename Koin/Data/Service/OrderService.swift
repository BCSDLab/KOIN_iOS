//
//  OrderService.swift
//  koin
//
//  Created by 이은지 on 7/7/25.
//

import Alamofire
import Combine

protocol OrderService {
    func fetchOrderShopList(requestModel: FetchOrderShopListRequest) -> AnyPublisher<[OrderShopDto], Error>
    func fetchOrderEventShop() -> AnyPublisher<[OrderShopEventDto], Error>
    func searchRelatedShops(text: String) -> AnyPublisher<RelatedKeywordsDto, Error>
    func fetchOrderShopMenus(orderableShopId: Int) -> AnyPublisher<[OrderShopMenusDto], Error>
    func fetchOrderShopMenusGroups(orderableShopId: Int) -> AnyPublisher<OrderShopMenusGroupsDto, Error>
    func fetchOrderShopSummary(orderableShopId: Int) -> AnyPublisher<OrderShopSummaryDto, Error>
    func fetchOrderInProgress() -> AnyPublisher<[OrderInProgress], Error>
    func fetchCartSummary(orderableShopId: Int) -> AnyPublisher<CartSummaryDto, Error>
    func fetchCartItemsCount() -> AnyPublisher<CartItemsCountDto, Error>
    func fetchCart() -> AnyPublisher<CartDto, Error>
    func resetCart() -> AnyPublisher<Void, ErrorResponse>
    func fetchOrderMenu(orderableShopId: Int, orderableShopMenuId: Int) -> AnyPublisher<OrderMenuDTO, Error>
}

final class DefaultOrderService: OrderService {
    
    let networkService = NetworkService()
    
    func fetchOrderShopList(requestModel: FetchOrderShopListRequest) -> AnyPublisher<[OrderShopDto], Error> {
        return request(.fetchOrderShopList(requestModel))
            .eraseToAnyPublisher()
    }
    
    func fetchOrderEventShop() -> AnyPublisher<[OrderShopEventDto], Error> {
        return request(.fetchOrderEventShop)
            .map { (response: OrderShopEventListResponseDto) in
                response.shopEvents
            }
            .eraseToAnyPublisher()
    }
    
    func searchRelatedShops(text: String) -> AnyPublisher<RelatedKeywordsDto, Error> {
        return request(.searchShop(text))
    }
    
    func fetchOrderShopMenus(orderableShopId: Int) -> AnyPublisher<[OrderShopMenusDto], Error> {
        return request(.fetchOrderShopMenus(orderableShopId: orderableShopId))
            .eraseToAnyPublisher()
    }
    func fetchOrderShopMenusGroups(orderableShopId: Int) -> AnyPublisher<OrderShopMenusGroupsDto, Error> {
        return request(.fetchOrderShopMenusGroups(orderableShopId: orderableShopId))
            .eraseToAnyPublisher()
    }
    func fetchOrderShopSummary(orderableShopId: Int) -> AnyPublisher<OrderShopSummaryDto, Error> {
        return request(.fetchOrderShopSummary(orderableShopId: orderableShopId))
            .eraseToAnyPublisher()
    }
    func fetchOrderInProgress() -> AnyPublisher<[OrderInProgress], Error> {
        request(.fetchOrderInProgress)
            .map { (dtos: [OrderInProgressDto]) in
                dtos.map { $0.toEntity() }
            }
            .eraseToAnyPublisher()
    }
    func fetchCartSummary(orderableShopId: Int) -> AnyPublisher<CartSummaryDto, Error> {
        request(.fetchCartSummary(orderableShopId: orderableShopId))
            .eraseToAnyPublisher()
    }
    func fetchCartItemsCount() -> AnyPublisher<CartItemsCountDto, Error> {
        request(.fetchCartItemsCount)
            .eraseToAnyPublisher()
    }
    
    func resetCart() -> AnyPublisher<Void, ErrorResponse> {
        return requestWithResponse(.resetCart)
            .eraseToAnyPublisher()
    }
    func fetchCart() -> AnyPublisher<CartDto, Error> {
        request(.fetchCart(parameter: "DELIVERY"))
            .catch { [weak self] error -> AnyPublisher<CartDto, Error> in
                guard let self = self else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
                switch error.asAFError?.responseCode {
                case 400:
                    return self.request(.fetchCart(parameter: "TAKE_OUT"))
                        .eraseToAnyPublisher()
                default:
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func fetchOrderMenu(orderableShopId: Int, orderableShopMenuId: Int) -> AnyPublisher<OrderMenuDTO, Error> {
        request(.fetchOrderMenu(orderableShopId: orderableShopId,
                                orderableShopMenuId: orderableShopMenuId))
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
    private func requestWithResponse(_ api: OrderAPI) -> AnyPublisher<Void, ErrorResponse> {
        return AF.request(api)
            .validate(statusCode: 200..<300)
            .publishData(emptyResponseCodes: [200])
            .tryMap { response in
                switch response.result {
                case .success:
                    return ()
                case .failure(let afError):
                    guard let response = response.response else {
                        throw URLError(.badServerResponse)
                    }
                    switch response.statusCode {
                    case 401:
                        throw ErrorResponse(code: "401", message: "")
                    default:
                        let afError = AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: response.statusCode))
                        throw afError
                    }
                }
            }
            .mapError { error -> ErrorResponse in
                self.handleError(error)
            }
            .eraseToAnyPublisher()
    }
    private func handleError(_ error: Error) -> ErrorResponse {
        if let errorResponse = error as? ErrorResponse {
            return errorResponse
        }
        return ErrorResponse(code: "", message: "알 수 없는 에러")
    }
}

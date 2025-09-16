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
    func fetchCartDelivery() -> AnyPublisher<CartDTO, Error>
    func fetchCartTakeOut() -> AnyPublisher<CartDTO, Error>
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
    
    var temp: Set<AnyCancellable> = []
    func resetCart() -> AnyPublisher<Void, Error> {
        (requestThatShowErrorMessage(.resetCart) as AnyPublisher<String, Error>)
            .sink(receiveCompletion: { completion in
                if case .failure(let failure) = completion {
                    print("failure: \(failure)")
                }
            }, receiveValue: {
                print("value: \($0)")
            })
            .store(in: &temp)
        
        
        return (requestThatShowErrorMessage(.resetCart) as AnyPublisher<String, Error>)
            .map { _ in
                return }
            .eraseToAnyPublisher( )
    }
    func fetchCartDelivery() -> AnyPublisher<CartDTO, Error> {
        requestThatShowErrorMessage(.fetchCartDelivery)
            .eraseToAnyPublisher()
    }
    func fetchCartTakeOut() -> AnyPublisher<CartDTO, Error> {
        requestThatShowErrorMessage(.fetchCartTakeOut)
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
    
    private func requestThatShowErrorMessage<T: Decodable>(_ api: OrderAPI) -> AnyPublisher<T, Error> {
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
                        // 디코딩 실패 시에도 서버 원문 바디 출력
                        if let raw = String(data: response.data ?? Data(), encoding: .utf8) {
                            print("Decoding failed. Raw body:", raw)
                        } else {
                            print("Decoding failed. Raw body: <\(response.data?.count ?? 0) bytes>")
                        }
                        throw error
                    }

                case .failure(let afError):
                    // 상태코드·본문 출력
                    let status = response.response?.statusCode ?? -1
                    let data = response.data ?? Data()
                    let body = String(data: data, encoding: .utf8) ?? "<\(data.count) bytes>"
                    // print("HTTP \(status) error body:", body)
                    throw afError
                }
            }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}

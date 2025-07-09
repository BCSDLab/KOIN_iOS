
import Foundation
import Combine

protocol OrderRepository {
    func fetchOrderShopList(requestModel: FetchOrderShopListRequest) -> AnyPublisher<[OrderShop], Error>
}

final class DefaultOrderRepository: OrderRepository {
    private let orderService: OrderService

    init(orderService: OrderService) {
        self.orderService = orderService
    }

    func fetchOrderShopList(requestModel: FetchOrderShopListRequest) -> AnyPublisher<[OrderShop], Error> {
        return orderService.fetchOrderShopList(requestModel: requestModel)
            .map { dtos in
                dtos.map(OrderShop.init)
            }
            .eraseToAnyPublisher()
    }
}

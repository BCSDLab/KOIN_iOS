
import Foundation
import Combine

protocol FetchOrderShopListUseCase {
    func execute(requestModel: FetchOrderShopListRequest) -> AnyPublisher<[OrderShop], Error>
}

final class DefaultFetchOrderShopListUseCase: FetchOrderShopListUseCase {
    private let orderRepository: OrderRepository

    init(orderRepository: OrderRepository) {
        self.orderRepository = orderRepository
    }

    func execute(requestModel: FetchOrderShopListRequest) -> AnyPublisher<[OrderShop], Error> {
        return orderRepository.fetchOrderShopList(requestModel: requestModel)
    }
}

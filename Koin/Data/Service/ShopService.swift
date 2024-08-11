//
//  ShopService.swift
//  koin
//
//  Created by 김나훈 on 5/22/24.
//

import Alamofire
import Combine

protocol ShopService {
    func fetchShopList() -> AnyPublisher<ShopsDTO, Error>
    func fetchEventList() -> AnyPublisher<EventsDTO, Error>
    func fetchShopCategoryList() -> AnyPublisher<ShopCategoryDTO, Error>
    func fetchShopData(requestModel: FetchShopInfoRequest) -> AnyPublisher<ShopDataDTO, Error>
    func fetchShopMenuList(requestModel: FetchShopInfoRequest) -> AnyPublisher<MenuDTO, Error>
    func fetchShopEventList(requestModel: FetchShopInfoRequest) -> AnyPublisher<EventsDTO, Error>
    func fetchShopReviewList(requestModel: FetchShopReviewRequest) -> AnyPublisher<ReviewsDTO, Error>
}

final class DefaultShopService: ShopService {
    
    func fetchShopList() -> AnyPublisher<ShopsDTO, Error> {
        return request(.fetchShopList)
    }

    func fetchEventList() -> AnyPublisher<EventsDTO, Error> {
        return request(.fetchEventList)
    }

    func fetchShopCategoryList() -> AnyPublisher<ShopCategoryDTO, Error> {
        return request(.fetchShopCategoryList)
    }
    
    func fetchShopData(requestModel: FetchShopInfoRequest) -> AnyPublisher<ShopDataDTO, Error> {
        return request(.fetchShopData(requestModel))
    }
    
    func fetchShopMenuList(requestModel: FetchShopInfoRequest) -> AnyPublisher<MenuDTO, Error> {
        return request(.fetchShopMenuList(requestModel))
    }
    
    func fetchShopEventList(requestModel: FetchShopInfoRequest) -> AnyPublisher<EventsDTO, Error> {
        return request(.fetchShopEventList(requestModel))
    }
    
    func fetchShopReviewList(requestModel: FetchShopReviewRequest) -> AnyPublisher<ReviewsDTO, Error> {
        return request(.fetchShopReviewList(requestModel))
    }

    private func request<T: Decodable>(_ api: ShopAPI) -> AnyPublisher<T, Error> {
        return AF.request(api)
            .publishDecodable(type: T.self)
            .value()
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}

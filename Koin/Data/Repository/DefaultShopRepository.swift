//
//  DefaultShopRepository.swift
//  koin
//
//  Created by 김나훈 on 5/22/24.
//

import Combine

final class DefaultShopRepository: ShopRepository {
    
    private let service: ShopService
    
    init(service: ShopService) {
        self.service = service
    }
    
    func fetchShopList() -> AnyPublisher<ShopsDTO, Error> {
        return service.fetchShopList()
    }
    
    func fetchEventList() -> AnyPublisher<EventsDTO, Error> {
        return service.fetchEventList()
    }
    
    func fetchShopCategoryList() -> AnyPublisher<ShopCategoryDTO, Error> {
        return service.fetchShopCategoryList()
    }
    
    func fetchShopData(requestModel: FetchShopInfoRequest) -> AnyPublisher<ShopDataDTO, Error> {
        return service.fetchShopData(requestModel: requestModel)
    }
    
    func fetchShopMenuList(requestModel: FetchShopInfoRequest) -> AnyPublisher<MenuDTO, Error> {
        return service.fetchShopMenuList(requestModel: requestModel)
    }
    
    func fetchShopEventList(requestModel: FetchShopInfoRequest) -> AnyPublisher<EventsDTO, Error> {
        return service.fetchShopEventList(requestModel: requestModel)
    }
    
    func fetchReviewList(requestModel: FetchShopReviewRequest) -> AnyPublisher<ReviewsDTO, Error> {
        return service.fetchShopReviewList(requestModel: requestModel)
    }
}

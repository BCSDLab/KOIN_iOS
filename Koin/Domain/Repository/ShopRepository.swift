//
//  ShopRepository.swift
//  koin
//
//  Created by 김나훈 on 5/22/24.
//

import Combine

protocol ShopRepository {
    func fetchShopList() -> AnyPublisher<ShopsDTO, Error>
    func fetchEventList() -> AnyPublisher<EventsDTO, Error>
    func fetchShopCategoryList() -> AnyPublisher<ShopCategoryDTO, Error>
    
    func fetchShopData(requestModel: FetchShopInfoRequest) -> AnyPublisher<ShopDataDTO, Error>
    func fetchShopMenuList(requestModel: FetchShopInfoRequest) -> AnyPublisher<MenuDTO, Error>
    func fetchShopEventList(requestModel: FetchShopInfoRequest) -> AnyPublisher<EventsDTO, Error>
    
    func fetchReviewList(requestModel: FetchShopReviewRequest) -> AnyPublisher<ReviewsDTO, Error>
}


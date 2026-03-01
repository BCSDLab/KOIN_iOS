//
//  DiningService.swift
//  koin
//
//  Created by 김나훈 on 6/7/24.
//

import Alamofire
import Combine

protocol DiningService {
    func fetchDiningList(requestModel: FetchDiningListRequest) -> AnyPublisher<[DiningDto], ErrorResponse>
    func fetchCoopShopList() -> AnyPublisher<CoopShopDto, ErrorResponse>
    func diningLike(requestModel: DiningLikeRequest, isLiked: Bool) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultDiningService: DiningService {
    
    private let networkService = NetworkService.shared
    
    func fetchDiningList(requestModel: FetchDiningListRequest) -> AnyPublisher<[DiningDto], ErrorResponse> {
        return networkService.requestWithResponse(api: DiningAPI.fetchDiningList(requestModel))
    }
    
    
    func fetchCoopShopList() -> AnyPublisher<CoopShopDto, ErrorResponse> {
        return networkService.requestWithResponse(api: DiningAPI.fetchCoopShopList)
    }
    
    func diningLike(requestModel: DiningLikeRequest, isLiked: Bool) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: DiningAPI.diningLike(requestModel, isLiked))
    }
}

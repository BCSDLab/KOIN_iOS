//
//  DiningRepository.swift
//  koin
//
//  Created by 김나훈 on 6/7/24.
//

import Combine

protocol DiningRepository {
    func fetchDiningList(requestModel: FetchDiningListRequest) -> AnyPublisher<[DiningDTO], ErrorResponse>
    func fetchCoopShopList() -> AnyPublisher<CoopShopDTO, Error>
    func diningLike(requestModel: DiningLikeRequest, isLiked: Bool) -> AnyPublisher<Void, ErrorResponse>
    func shareMenuList(shareModel: ShareDiningMenu)
}

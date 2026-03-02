//
//  DefaultDiningRepository.swift
//  koin
//
//  Created by 김나훈 on 6/7/24.
//

import Combine

final class DefaultDiningRepository: DiningRepository {
    private let diningService: DiningService
    private let shareService: ShareService
    
    init(diningService: DiningService, shareService: ShareService) {
        self.diningService = diningService
        self.shareService = shareService
    }
    
    func fetchDiningList(requestModel: FetchDiningListRequest) -> AnyPublisher<[DiningDto], ErrorResponse> {
        return diningService.fetchDiningList(requestModel: requestModel, retry: false)
    }
    
    func fetchCoopShopList() -> AnyPublisher<CoopShopDto, Error> {
        return diningService.fetchCoopShopList()
    }
    
    func diningLike(requestModel: DiningLikeRequest, isLiked: Bool) -> AnyPublisher<Void, ErrorResponse> {
        return diningService.diningLike(requestModel: requestModel, isLiked: isLiked)
    }
    
    func shareMenuList(shareModel: ShareDiningMenu) {
        shareService.shareMenuList(shareModel: shareModel)
    }
  
}

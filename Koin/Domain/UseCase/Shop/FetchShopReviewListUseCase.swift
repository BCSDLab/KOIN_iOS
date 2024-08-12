//
//  FetchShopReviewListUseCase.swift
//  koin
//
//  Created by 김나훈 on 7/9/24.
//

import Combine

protocol FetchShopReviewListUseCase {
    func execute(requestModel: FetchShopReviewRequest) -> AnyPublisher<ShopReview, Error>}

final class DefaultFetchShopReviewListUseCase: FetchShopReviewListUseCase {
    
    private let shopRepository: ShopRepository
    
    init(shopRepository: ShopRepository) {
        self.shopRepository = shopRepository
    }
    
    func execute(requestModel: FetchShopReviewRequest) -> AnyPublisher<ShopReview, Error> {
        return shopRepository.fetchReviewList(requestModel: requestModel)
            .map { reviewsDTO in
                reviewsDTO.toDomain(shopId: requestModel.shopId) 
            }
            .eraseToAnyPublisher()
    }
}

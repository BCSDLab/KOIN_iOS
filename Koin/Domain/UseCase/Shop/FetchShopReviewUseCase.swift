//
//  FetchShopReviewUseCase.swift
//  koin
//
//  Created by 김나훈 on 8/12/24.
//

import Combine

protocol FetchShopReviewUseCase {
    func execute(reviewId: Int, shopId: Int) -> AnyPublisher<OneReviewDTO, ErrorResponse>
}

final class DefaultFetchShopReviewUseCase: FetchShopReviewUseCase {
    
    private let shopRepository: ShopRepository
    
    init(shopRepository: ShopRepository) {
        self.shopRepository = shopRepository
    }
    
    func execute(reviewId: Int, shopId: Int) -> AnyPublisher<OneReviewDTO, ErrorResponse> {
        return shopRepository.fetchReview(reviewId: reviewId, shopId: shopId)
    }
}

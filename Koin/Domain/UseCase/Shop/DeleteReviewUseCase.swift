//
//  DeleteReviewUseCase.swift
//  koin
//
//  Created by 김나훈 on 8/12/24.
//

import Combine

protocol DeleteReviewUseCase {
    func execute(reviewId: Int, shopId: Int) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultDeleteReviewUseCase: DeleteReviewUseCase {
    
    private let shopRepository: ShopRepository
    
    init(shopRepository: ShopRepository) {
        self.shopRepository = shopRepository
    }
    
    func execute(reviewId: Int, shopId: Int) -> AnyPublisher<Void, ErrorResponse> {
        return shopRepository.deleteReview(reviewId: reviewId, shopId: shopId)
    }
}

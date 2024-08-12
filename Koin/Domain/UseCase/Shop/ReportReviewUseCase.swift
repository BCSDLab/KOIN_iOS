//
//  ReportReviewUseCase.swift
//  koin
//
//  Created by 김나훈 on 8/12/24.
//

import Combine

protocol ReportReviewReviewUseCase {
    func execute(reviewId: Int, shopId: Int, requestModel: ReportReviewRequest) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultReportReviewUseCase: ReportReviewReviewUseCase {
    
    private let shopRepository: ShopRepository
    
    init(shopRepository: ShopRepository) {
        self.shopRepository = shopRepository
    }
    
    func execute(reviewId: Int, shopId: Int, requestModel: ReportReviewRequest) -> AnyPublisher<Void, ErrorResponse> {
        return shopRepository.reportReview(reviewId: reviewId, shopId: shopId, requestModel: requestModel)
    }
}

//
//  ReportReviewUseCase.swift
//  koin
//
//  Created by 김나훈 on 8/12/24.
//

import Combine

protocol ReportReviewReviewUseCase {
    func execute(requestModel: ReportReviewRequest, reviewId: Int, shopId: Int) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultReportReviewUseCase: ReportReviewReviewUseCase {
    
    private let shopRepository: ShopRepository
    
    init(shopRepository: ShopRepository) {
        self.shopRepository = shopRepository
    }
    
    func execute(requestModel: ReportReviewRequest, reviewId: Int, shopId: Int) -> AnyPublisher<Void, ErrorResponse> {
        return shopRepository.reportReview(requestModel: requestModel, reviewId: reviewId, shopId: shopId)
    }
}

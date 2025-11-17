//
//  FetchMyReviewUseCase.swift
//  koin
//
//  Created by 김나훈 on 8/12/24.
//

import Combine

protocol FetchMyReviewUseCase {
    func execute(requestModel: FetchMyReviewRequest, shopId: Int) -> AnyPublisher<[Review], ErrorResponse>
}

final class DefaultFetchMyReviewUseCase: FetchMyReviewUseCase {
    
    private let shopRepository: ShopRepository
    
    init(shopRepository: ShopRepository) {
        self.shopRepository = shopRepository
    }
    
    func execute(requestModel: FetchMyReviewRequest, shopId: Int) -> AnyPublisher<[Review], ErrorResponse> {
        return shopRepository.fetchMyReviewList(requestModel: requestModel, shopId: shopId)
            .map { myReviewDto in
                return myReviewDto.toDomain(shopId: shopId)
            }
            .eraseToAnyPublisher()
    }
}

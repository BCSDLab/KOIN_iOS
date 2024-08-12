//
//  ShopReviewViewModel.swift
//  koin
//
//  Created by 김나훈 on 7/8/24.
//

import Combine

final class ShopReviewViewModel: ViewModelProtocol {
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let postReviewUseCase: PostReviewUseCase
    private let modifyReviewUseCase: ModifyReviewUseCase
    private let fetchShopReviewUseCase: FetchShopReviewUseCase
    private let reviewId: Int?
    private let shopId: Int
    
    enum Input {
        case writeReview(WriteReviewRequest)
    }
    
    enum Output {
        case fillComponent(OneReviewDTO)
        case dissmissView
    }
    
    init(postReviewUseCase: PostReviewUseCase, modifyReviewUseCase: ModifyReviewUseCase, fetchShopReviewUseCase: FetchShopReviewUseCase, reviewId: Int? = nil, shopId: Int) {
        self.postReviewUseCase = postReviewUseCase
        self.modifyReviewUseCase = modifyReviewUseCase
        self.fetchShopReviewUseCase = fetchShopReviewUseCase
        self.reviewId = reviewId
        self.shopId = shopId
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            guard let self = self else { return }
            switch input {
            case let .writeReview(requestModel):
                if let reviewId = self.reviewId { self.modifyReview(requestModel: requestModel, reviewId: reviewId) }
                else { self.postReview(requestModel: requestModel) }
            }
            
        }.store(in: &subscriptions)
        
        return outputSubject.eraseToAnyPublisher()
    }
    
    private func fetchShopReview() {
        guard let reviewId = reviewId else { return }
        fetchShopReviewUseCase.execute(reviewId: reviewId, shopId: shopId).sink { completion in
            print(completion)
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.fillComponent(response))
        }.store(in: &subscriptions)
    }
    
    private func postReview(requestModel: WriteReviewRequest) {
        postReviewUseCase.execute(requestModel: requestModel, shopId: shopId).sink { completion in
            print(completion)
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.dissmissView)
        }.store(in: &subscriptions)
    }
    
    private func modifyReview(requestModel: WriteReviewRequest, reviewId: Int) {
        modifyReviewUseCase.execute(requestModel: requestModel, reviewId: reviewId, shopId: shopId).sink { completion in
            print(completion)
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.dissmissView)
        }.store(in: &subscriptions)
        
    }
}

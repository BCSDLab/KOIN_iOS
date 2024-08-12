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
    private let reviewId: Int?
    private let shopId: Int
    
    enum Input {
        case writeReview
    }
    
    enum Output {
     
    }
    
    init(reviewId: Int? = nil, shopId: Int) {
        self.reviewId = reviewId
        self.shopId = shopId
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            guard let self = self else { return }
            switch input {
            case .writeReview:
                if let reviewId = self.reviewId { self.modifyReview(reviewId: reviewId) }
                else { self.postReview() }
            }
            
        }.store(in: &subscriptions)
        
        return outputSubject.eraseToAnyPublisher()
    }
    private func postReview() {
        // 최초 작성
    }
    
    private func modifyReview(reviewId: Int) {
        // 수정
    }
}

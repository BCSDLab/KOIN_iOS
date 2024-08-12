//
//  ShopReviewReportViewModel.swift
//  koin
//
//  Created by 김나훈 on 8/12/24.
//

import Combine

final class ShopReviewReportViewModel: ViewModelProtocol {
    
    // MARK: - Input
    
    enum Input {
        case reportReview
    }
    
    // MARK: - Output
    
    enum Output {
      
    }
    
    // MARK: - Properties
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let reviewId: Int
    private let shopId: Int
    
    // MARK: - Initialization
    
    init(reviewId: Int, shopId: Int) {
        self.reviewId = reviewId
        self.shopId = shopId
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case .reportReview:
                self?.reportReview()
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
    
}

extension ShopReviewReportViewModel {
   
    private func reportReview() {
    
    }

}

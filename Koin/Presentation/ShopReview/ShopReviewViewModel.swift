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
       
    }
    
    enum Output {
     
    }
    
    init(reviewId: Int? = nil, shopId: Int) {
        self.reviewId = reviewId
        self.shopId = shopId
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
          
            
        }.store(in: &subscriptions)
        
        return outputSubject.eraseToAnyPublisher()
    }
}

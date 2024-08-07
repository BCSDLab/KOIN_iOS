//
//  DiningLikeUseCase.swift
//  koin
//
//  Created by 김나훈 on 7/28/24.
//

import Combine
import Foundation

protocol DiningLikeUseCase {
    func execute(diningId: Int, isLiked: Bool) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultDiningLikeUseCase: DiningLikeUseCase {
    
    private let diningRepository: DiningRepository
    
    init(diningRepository: DiningRepository) {
        self.diningRepository = diningRepository
    }
    
    func execute(diningId: Int, isLiked: Bool) -> AnyPublisher<Void, ErrorResponse> {
        diningRepository.diningLike(requestModel: DiningLikeRequest(diningId: diningId), isLiked: isLiked)
    }
    
}

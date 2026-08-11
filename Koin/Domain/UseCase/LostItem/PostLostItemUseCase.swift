//
//  PostLostItemUseCase.swift
//  koin
//
//  Created by 김나훈 on 1/15/25.
//

import Combine

protocol PostLostItemUseCase {
    func execute(request: [PostLostItemRequest]) -> AnyPublisher<LostItemData, ErrorResponse>
}

final class DefaultPostLostItemUseCase: PostLostItemUseCase {
    
    private let lostItemRepository: LostItemRepository
    
    init(lostItemRepository: LostItemRepository) {
        self.lostItemRepository = lostItemRepository
    }
    
    func execute(request: [PostLostItemRequest]) -> AnyPublisher<LostItemData, ErrorResponse> {
        lostItemRepository.postLostItem(request: request)
    }
}

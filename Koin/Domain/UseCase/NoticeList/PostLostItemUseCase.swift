//
//  PostLostItemUseCase.swift
//  koin
//
//  Created by 김나훈 on 1/15/25.
//

import Combine

protocol PostLostItemUseCase {
    func execute(request: [PostLostItemRequest]) -> AnyPublisher<LostItemDataDto, ErrorResponse>
}

final class DefaultPostLostItemUseCase: PostLostItemUseCase {
    
    private let noticeListRepository: NoticeListRepository
    
    init(noticeListRepository: NoticeListRepository) {
        self.noticeListRepository = noticeListRepository
    }
    
    func execute(request: [PostLostItemRequest]) -> AnyPublisher<LostItemDataDto, ErrorResponse> {
        noticeListRepository.postLostItem(request: request)
    }
}

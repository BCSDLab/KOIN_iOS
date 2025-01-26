//
//  PostLostItemUseCase.swift
//  koin
//
//  Created by 김나훈 on 1/15/25.
//

import Combine

protocol PostLostItemUseCase {
    func execute(request: [PostLostArticleRequest]) -> AnyPublisher<LostArticleDetailDTO, ErrorResponse>
}

final class DefaultPostLostItemUseCase: PostLostItemUseCase {
    
    private let noticeListRepository: NoticeListRepository
    
    init(noticeListRepository: NoticeListRepository) {
        self.noticeListRepository = noticeListRepository
    }
    
    func execute(request: [PostLostArticleRequest]) -> AnyPublisher<LostArticleDetailDTO, ErrorResponse> {
        noticeListRepository.postLostItem(request: request)
    }
}

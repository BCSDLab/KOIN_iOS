//
//  FetchLostItemUseCase.swift
//  koin
//
//  Created by 김나훈 on 1/15/25.
//

import Combine

protocol FetchLostItemUseCase {
    func execute(id: Int) -> AnyPublisher<LostArticleDetailDTO, Error>
}

final class DefaultFetchLostItemUseCase: FetchLostItemUseCase {
    
    private let noticeListRepository: NoticeListRepository
    
    init(noticeListRepository: NoticeListRepository) {
        self.noticeListRepository = noticeListRepository
    }
    
    func execute(id: Int) -> AnyPublisher<LostArticleDetailDTO, Error> {
        noticeListRepository.fetchLostItem(id: id)
    }
}

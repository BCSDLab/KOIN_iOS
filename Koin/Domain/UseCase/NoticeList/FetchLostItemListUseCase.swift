//
//  FetchLostItemListUseCase.swift
//  koin
//
//  Created by 김나훈 on 1/15/25.
//

import Combine

protocol FetchLostItemListUseCase {
    func execute(page: Int, limit: Int) -> AnyPublisher<LostArticleDTO, Error>
}

final class DefaultFetchLostItemListUseCase: FetchLostItemListUseCase {
    
    private let noticeListRepository: NoticeListRepository
    
    init(noticeListRepository: NoticeListRepository) {
        self.noticeListRepository = noticeListRepository
    }
    
    func execute(page: Int, limit: Int) -> AnyPublisher<LostArticleDTO, Error> {
        noticeListRepository.fetchLostItemList(page: page, limit: limit)
    }
}

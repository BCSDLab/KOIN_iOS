//
//  FetchHotNoticeArticlesUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/20/24.
//

import Combine
import Foundation

protocol FetchHotNoticeArticlesUseCase {
    func execute(noticeId: Int?) -> AnyPublisher<[NoticeArticleDto], Error>
}

final class DefaultFetchHotNoticeArticlesUseCase: FetchHotNoticeArticlesUseCase {
    let noticeListRepository: NoticeListRepository
    
    init(noticeListRepository: NoticeListRepository) {
        self.noticeListRepository = noticeListRepository
    }
    
    func execute(noticeId: Int? = nil) -> AnyPublisher<[NoticeArticleDto], Error> {
        return noticeListRepository.fetchHotNoticeArticle()
            .map { noticeArticles in
                var filteredArticles: [NoticeArticleDto]
                
                if let noticeId = noticeId {
                    filteredArticles = noticeArticles.filter { $0.id != noticeId }.map {
                        $0.toDomainWithChangedDate()
                    }
                } else {
                    filteredArticles = noticeArticles.map {
                        $0.toDomainWithChangedDate()
                    }
                }
                return Array(filteredArticles.prefix(4))
            }
            .eraseToAnyPublisher()
    }
}

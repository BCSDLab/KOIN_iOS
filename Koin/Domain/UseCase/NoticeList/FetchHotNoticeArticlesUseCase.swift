//
//  FetchHotNoticeArticlesUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/20/24.
//

import Combine
import Foundation

protocol FetchHotNoticeArticlesUseCase {
    func execute(noticeId: Int?) -> AnyPublisher<[NoticeArticleDTO], Error>
}

final class DefaultFetchHotNoticeArticlesUseCase: FetchHotNoticeArticlesUseCase {
    let noticeListRepository: NoticeListRepository
    
    init(noticeListRepository: NoticeListRepository) {
        self.noticeListRepository = noticeListRepository
    }
    
    func execute(noticeId: Int? = nil) -> AnyPublisher<[NoticeArticleDTO], Error> {
        return noticeListRepository.fetchHotNoticeArticle()
            .map { noticeArticles in
                if let noticeId = noticeId {
                    return noticeArticles.filter { $0.id != noticeId }
                }
                return noticeArticles
            }
            .eraseToAnyPublisher()
    }
    
}

//
//  FetchHotNoticeArticlesUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/20/24.
//

import Combine
import Foundation

protocol FetchHotNoticeArticlesUseCase {
    func execute() -> AnyPublisher<[NoticeArticleDTO], Error>
}

final class DefaultFetchHotNoticeArticlesUseCase: FetchHotNoticeArticlesUseCase {
    let noticeListRepository: NoticeListRepository
    
    init(noticeListRepository: NoticeListRepository) {
        self.noticeListRepository = noticeListRepository
    }
    
    func execute() -> AnyPublisher<[NoticeArticleDTO], Error> {
        return noticeListRepository.fetchHotNoticeArticle().eraseToAnyPublisher()
    }
    
}

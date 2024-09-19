//
//  SearchNoticeArticlesUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 9/19/24.
//

import Combine
import Foundation

protocol SearchNoticeArticlesUseCase {
    func execute(requestModel: SearchNoticeArticleRequest) -> AnyPublisher<NoticeListDTO, Error>
}

final class DefaultSearchNoticeArticlesUseCase: SearchNoticeArticlesUseCase {
    private let noticeRepository: NoticeListRepository
    
    init(noticeRepository: NoticeListRepository) {
        self.noticeRepository = noticeRepository
    }
    
    func execute(requestModel: SearchNoticeArticleRequest) -> AnyPublisher<NoticeListDTO, Error> {
        return noticeRepository.searchNoticeArticle(requestModel: requestModel).eraseToAnyPublisher()
    }
}

//
//  NoticeListRepository.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/17/24.
//

import Combine

protocol NoticeListRepository {
    func fetchNoticeArticles(requestModel: FetchNoticeArticlesRequest) -> AnyPublisher<NoticeListDTO, Error>
    func searchNoticeArticle(requestModel: SearchNoticeArticleRequest) -> AnyPublisher<NoticeListDTO, Error>
    func fetchNoticeData(requestModel: FetchNoticeDataRequest) -> AnyPublisher<NoticeArticleDTO, Error>
    func fetchHotNoticeArticle() -> AnyPublisher<[NoticeArticleDTO], Error>
    func createNotificationKeyWord(requestModel: NoticeKeyWordDTO) -> AnyPublisher<NoticeKeyWordDTO, ErrorResponse>
    func deleteNotificationKeyWord(requestModel: Int) -> AnyPublisher<Void, ErrorResponse>
    func fetchNotificationKeyWord(isMyKeyWord: Bool) -> AnyPublisher<NoticeKeyWordsDTO, ErrorResponse>
}

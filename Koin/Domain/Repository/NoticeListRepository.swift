//
//  NoticeListRepository.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/17/24.
//

import Combine
import Foundation

protocol NoticeListRepository {
    func fetchNoticeArticles(requestModel: FetchNoticeArticlesRequest) -> AnyPublisher<NoticeListDTO, Error>
    func searchNoticeArticle(requestModel: SearchNoticeArticleRequest) -> AnyPublisher<NoticeListDTO, Error>
    func fetchNoticeData(requestModel: FetchNoticeDataRequest) -> AnyPublisher<NoticeArticleDTO, Error>
    func fetchHotNoticeArticle() -> AnyPublisher<[NoticeArticleDTO], Error>
    func createNotificationKeyWord(requestModel: NoticeKeyWordDTO) -> AnyPublisher<NoticeKeyWordDTO, ErrorResponse>
    func deleteNotificationKeyWord(requestModel: NoticeKeyWordDTO) -> AnyPublisher<Void, ErrorResponse>
    func fetchNotificationKeyWord() -> AnyPublisher<NoticeKeywordsFetchResult, ErrorResponse>
    func fetchRecommendedKeyWord(count: Int?) -> AnyPublisher<NoticeRecommendedKeyWordDTO, Error>
    func downloadNoticeAttachment(downloadUrl: String, fileName: String) -> AnyPublisher<Void, ErrorResponse>
    func manageRecentSearchedWord(name: String, date: Date, actionType: Int)
    func fetchRecentSearchedWord() -> [RecentSearchedWordInfo]
}

//
//  NoticeListRepository.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/17/24.
//

import Combine
import Foundation

protocol NoticeListRepository {
    func fetchNoticeArticles(requestModel: FetchNoticeArticlesRequest) -> AnyPublisher<NoticeListDto, ErrorResponse>
    func searchNoticeArticle(requestModel: SearchNoticeArticleRequest) -> AnyPublisher<NoticeListDto, ErrorResponse>
    func fetchNoticeData(requestModel: FetchNoticeDataRequest) -> AnyPublisher<NoticeArticleDto, ErrorResponse>
    func fetchHotNoticeArticle() -> AnyPublisher<[NoticeArticleDto], ErrorResponse>
    func createNotificationKeyword(requestModel: NoticeKeywordDto) -> AnyPublisher<NoticeKeywordDto, ErrorResponse>
    func deleteNotificationKeyword(requestModel: NoticeKeywordDto) -> AnyPublisher<Void, ErrorResponse>
    func fetchNotificationKeyword() -> AnyPublisher<NoticeKeywordsFetchResult, ErrorResponse>
    func fetchRecommendedKeyword(count: Int?) -> AnyPublisher<NoticeRecommendedKeywordDto, ErrorResponse>
    func downloadNoticeAttachment(downloadUrl: String, fileName: String) -> AnyPublisher<URL?, ErrorResponse>
    func manageRecentSearchedWord(name: String, date: Date, actionType: Int)
    func fetchRecentSearchedWord() -> [RecentSearchedWordInfo]
}

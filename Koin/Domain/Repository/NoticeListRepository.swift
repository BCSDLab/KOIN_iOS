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
    func createNotificationKeyword(requestModel: NoticeKeywordDTO) -> AnyPublisher<NoticeKeywordDTO, ErrorResponse>
    func deleteNotificationKeyword(requestModel: NoticeKeywordDTO) -> AnyPublisher<Void, ErrorResponse>
    func fetchNotificationKeyword() -> AnyPublisher<NoticeKeywordsFetchResult, ErrorResponse>
    func fetchRecommendedKeyword(count: Int?) -> AnyPublisher<NoticeRecommendedKeywordDTO, Error>
    func downloadNoticeAttachment(downloadUrl: String, fileName: String) -> AnyPublisher<URL?, ErrorResponse>
    func manageRecentSearchedWord(name: String, date: Date, actionType: Int)
    func fetchRecentSearchedWord() -> [RecentSearchedWordInfo]
    func postLostItem(request: [PostLostItemRequest]) -> AnyPublisher<LostArticleDetailDTO, ErrorResponse>
    func fetchLostItemList(requestModel: FetchNoticeArticlesRequest) -> AnyPublisher<NoticeListDTO, Error>
    func fetchLostItem(id: Int) -> AnyPublisher<LostArticleDetailDTO, ErrorResponse>
    func deleteLostItem(id: Int) -> AnyPublisher<Void, ErrorResponse>
    
}

//
//  NoticeListRepository.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/17/24.
//

import Combine
import Foundation

protocol NoticeListRepository {
    func fetchNoticeArticles(requestModel: FetchNoticeArticlesRequest) -> AnyPublisher<NoticeListDto, Error>
    func searchNoticeArticle(requestModel: SearchNoticeArticleRequest) -> AnyPublisher<NoticeListDto, Error>
    func fetchLostItemArticles(requestModel: FetchLostItemsRequest) -> AnyPublisher<NoticeListDto, Error>
    func fetchNoticeData(requestModel: FetchNoticeDataRequest) -> AnyPublisher<NoticeArticleDto, Error>
    func fetchHotNoticeArticle() -> AnyPublisher<[NoticeArticleDto], Error>
    func createNotificationKeyword(requestModel: NoticeKeywordDto) -> AnyPublisher<NoticeKeywordDto, ErrorResponse>
    func deleteNotificationKeyword(requestModel: NoticeKeywordDto) -> AnyPublisher<Void, ErrorResponse>
    func fetchNotificationKeyword() -> AnyPublisher<NoticeKeywordsFetchResult, ErrorResponse>
    func fetchRecommendedKeyword(count: Int?) -> AnyPublisher<NoticeRecommendedKeywordDto, Error>
    func downloadNoticeAttachment(downloadUrl: String, fileName: String) -> AnyPublisher<URL?, ErrorResponse>
    func manageRecentSearchedWord(name: String, date: Date, actionType: Int)
    func fetchRecentSearchedWord() -> [RecentSearchedWordInfo]
    func postLostItem(request: [PostLostItemRequest]) -> AnyPublisher<LostItemDataDto, ErrorResponse>
    func fetchLostItem(id: Int) -> AnyPublisher<LostArticleDetailDto, ErrorResponse>
    func deleteLostItem(id: Int) -> AnyPublisher<Void, ErrorResponse>
    func reportLostItemArticle(id: Int, request: ReportLostItemRequest) -> AnyPublisher<Void, ErrorResponse>
}

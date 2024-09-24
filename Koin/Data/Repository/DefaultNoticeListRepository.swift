//
//  DefaultNoticeListRepository.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/17/24.
//

import Combine
import Foundation

final class DefaultNoticeListRepository: NoticeListRepository {
    private let service: NoticeListService
    
    init(service: NoticeListService) {
        self.service = service
    }
    
    func fetchNoticeArticles(requestModel: FetchNoticeArticlesRequest) -> AnyPublisher<NoticeListDTO, Error> {
        return service.fetchNoticeArticles(requestModel: requestModel)
    }
    
    func searchNoticeArticle(requestModel: SearchNoticeArticleRequest) -> AnyPublisher<NoticeListDTO, Error> {
        return service.searchNoticeArticle(requestModel: requestModel)
    }
    
    func fetchNoticeData(requestModel: FetchNoticeDataRequest) -> AnyPublisher<NoticeArticleDTO, Error> {
        return service.fetchNoticeData(requestModel: requestModel)
    }
    
    func fetchHotNoticeArticle() -> AnyPublisher<[NoticeArticleDTO], Error> {
        return service.fetchHotNoticeArticles()
    }
    
    func createNotificationKeyword(requestModel: NoticeKeywordDTO) -> AnyPublisher<NoticeKeywordDTO, ErrorResponse> {
        return service.createNotificationKeyword(requestModel: requestModel)
    }
    
    func deleteNotificationKeyword(requestModel: NoticeKeywordDTO) -> AnyPublisher<Void, ErrorResponse> {
        return service.deleteNotificationKeyword(requestModel: requestModel)
    }
    
    func fetchNotificationKeyword() -> AnyPublisher<NoticeKeywordsFetchResult, ErrorResponse> {
        return service.fetchMyNotificationKeyword()
    }
    
    func fetchRecommendedKeyword(count: Int?) -> AnyPublisher<NoticeRecommendedKeywordDTO, Error> {
        return service.fetchRecommendedKeyword(count: count)
    }
    
    func downloadNoticeAttachment(downloadUrl: String, fileName: String) -> AnyPublisher<Void, ErrorResponse> {
        return service.downloadNoticeAttachment(downloadUrl: downloadUrl, fileName: fileName)
    }
    
    func manageRecentSearchedWord(name: String, date: Date, actionType: Int) {
        return service.manageRecentSearchedWord(name: name, date: date, actionType: actionType)
    }
    
    func fetchRecentSearchedWord() -> [RecentSearchedWordInfo] {
        return service.fetchRecentSearchedWord()
    }
}


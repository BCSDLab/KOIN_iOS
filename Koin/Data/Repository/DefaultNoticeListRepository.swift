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
    
    func createNotificationKeyWord(requestModel: NoticeKeyWordDTO) -> AnyPublisher<NoticeKeyWordDTO, ErrorResponse> {
        return service.createNotificationKeyWord(requestModel: requestModel)
    }
    
    func deleteNotificationKeyWord(requestModel: NoticeKeyWordDTO) -> AnyPublisher<Void, ErrorResponse> {
        return service.deleteNotificationKeyWord(requestModel: requestModel)
    }
    
    func fetchNotificationKeyWord() -> AnyPublisher<NoticeKeywordsFetchResult, ErrorResponse> {
        return service.fetchMyNotificationKeyWord()
    }
    
    func fetchRecommendedKeyWord(count: Int?) -> AnyPublisher<NoticeRecommendedKeyWordDTO, Error> {
        return service.fetchRecommendedKeyWord(count: count)
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


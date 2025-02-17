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
    
    func fetchLostItemArticles(requestModel: FetchLostItemsRequest) -> AnyPublisher<NoticeListDTO, Error> {
        service.fetchLostItemArticles(requestModel: requestModel, retry: false)
    }
    
    
    func reportLostItemArticle(id: Int, request: ReportLostItemRequest) -> AnyPublisher<Void, ErrorResponse> {
        service.reportLostItemArticle(id: id, request: request)
    }
    
    func deleteLostItem(id: Int) -> AnyPublisher<Void, ErrorResponse> {
        service.deleteLostItem(id: id)
    }
    
    func postLostItem(request: [PostLostItemRequest]) -> AnyPublisher<LostArticleDetailDTO, ErrorResponse> {
        service.postLostItem(request: request)
    }
    
    func fetchLostItem(id: Int) -> AnyPublisher<LostArticleDetailDTO, ErrorResponse> {
        service.fetchLostItem(id: id, retry: false)
    }
    
    
    func fetchNoticeArticles(requestModel: FetchNoticeArticlesRequest) -> AnyPublisher<NoticeListDTO, Error> {
        return service.fetchNoticeArticles(requestModel: requestModel)
    }
    
    func fetchLostItemList(requestModel: FetchNoticeArticlesRequest) -> AnyPublisher<NoticeListDTO, Error> {
        return service.fetchLostItemList(requestModel: requestModel)
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
    
    func downloadNoticeAttachment(downloadUrl: String, fileName: String) -> AnyPublisher<URL?, ErrorResponse> {
        return service.downloadNoticeAttachment(downloadUrl: downloadUrl, fileName: fileName)
    }
    
    func manageRecentSearchedWord(name: String, date: Date, actionType: Int) {
        return service.manageRecentSearchedWord(name: name, date: date, actionType: actionType)
    }
    
    func fetchRecentSearchedWord() -> [RecentSearchedWordInfo] {
        return service.fetchRecentSearchedWord()
    }
}


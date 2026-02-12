//
//  NoticeListService.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/17/24.
//

import Foundation
import Alamofire
import Combine

protocol NoticeListService {
    func fetchNoticeArticles(requestModel: FetchNoticeArticlesRequest) -> AnyPublisher<NoticeListDto, Error>
    func searchNoticeArticle(requestModel: SearchNoticeArticleRequest) -> AnyPublisher<NoticeListDto, Error>
    func fetchLostItemArticles(requestModel: FetchLostItemsRequest) -> AnyPublisher<NoticeListDto, Error>
    func fetchNoticeData(requestModel: FetchNoticeDataRequest) -> AnyPublisher<NoticeArticleDto, Error>
    func fetchHotNoticeArticles() -> AnyPublisher<[NoticeArticleDto], Error>
    func createNotificationKeyword(requestModel: NoticeKeywordDto) -> AnyPublisher<NoticeKeywordDto, ErrorResponse>
    func deleteNotificationKeyword(requestModel: NoticeKeywordDto) -> AnyPublisher<Void, ErrorResponse>
    func fetchMyNotificationKeyword() -> AnyPublisher<NoticeKeywordsFetchResult, ErrorResponse>
    func fetchRecommendedKeyword(count: Int?) -> AnyPublisher<NoticeRecommendedKeywordDto, Error>
    func downloadNoticeAttachment(downloadUrl: String, fileName: String) -> AnyPublisher<URL?, ErrorResponse>
    func manageRecentSearchedWord(name: String, date: Date, actionType: Int)
    func fetchRecentSearchedWord() -> [RecentSearchedWordInfo]
    func postLostItem(request: [PostLostItemRequest]) -> AnyPublisher<LostItemDataDto, ErrorResponse>
    func fetchLostItemList(requestModel: FetchNoticeArticlesRequest) -> AnyPublisher<NoticeListDto, Error>
    func fetchLostItem(id: Int) -> AnyPublisher<LostArticleDetailDto, ErrorResponse>
    func deleteLostItem(id: Int) -> AnyPublisher<Void, ErrorResponse>
    func reportLostItemArticle(id: Int, request: ReportLostItemRequest) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultNoticeService: NoticeListService {
        
    private let networkService = NetworkService()
    private let coreDataService = CoreDataService.shared
    
    func fetchLostItemArticles(requestModel: FetchLostItemsRequest) -> AnyPublisher<NoticeListDto, Error> {
        return networkService.requestWithResponse(api: NoticeListAPI.fetchLostItemArticles(requestModel))
    }
    
    func reportLostItemArticle(id: Int, request: ReportLostItemRequest) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: NoticeListAPI.reportLostItem(id, request))
    }
    
    func postLostItem(request: [PostLostItemRequest]) -> AnyPublisher<LostItemDataDto, ErrorResponse> {
        return networkService.requestWithResponse(api: NoticeListAPI.postLostItem(request))
    }
    
    func fetchLostItemList(requestModel: FetchNoticeArticlesRequest) -> AnyPublisher<NoticeListDto, Error> {
        return networkService.requestWithResponse(api: NoticeListAPI.fetchLostItemList(requestModel))
    }
    
    func fetchLostItem(id: Int) -> AnyPublisher<LostArticleDetailDto, ErrorResponse> {
        return networkService.requestWithResponse(api: NoticeListAPI.fetchLostItem(id))
    }
    
    func deleteLostItem(id: Int) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: NoticeListAPI.deleteLostItem(id))
    }
    
    func fetchNoticeArticles(requestModel: FetchNoticeArticlesRequest) -> AnyPublisher<NoticeListDto, Error> {
        return networkService.requestWithResponse(api: NoticeListAPI.fetchNoticeArticles(requestModel))
    }
    
    func searchNoticeArticle(requestModel: SearchNoticeArticleRequest) -> AnyPublisher<NoticeListDto, Error> {
        return networkService.requestWithResponse(api: NoticeListAPI.searchNoticeArticle(requestModel))
    }
    
    func fetchNoticeData(requestModel: FetchNoticeDataRequest) -> AnyPublisher<NoticeArticleDto, Error> {
        return networkService.requestWithResponse(api: NoticeListAPI.fetchNoticeData(requestModel))
    }
    
    func fetchHotNoticeArticles() -> AnyPublisher<[NoticeArticleDto], Error> {
        return networkService.requestWithResponse(api: NoticeListAPI.fetchHotNoticeArticles)
    }
    
    func createNotificationKeyword(requestModel: NoticeKeywordDto) -> AnyPublisher<NoticeKeywordDto, ErrorResponse> {
        return networkService.requestWithResponse(api: NoticeListAPI.createNotificationKeyword(requestModel))
            .catch { [weak self] error -> AnyPublisher<NoticeKeywordDto, ErrorResponse> in
                guard let self else { return Fail(error: error).eraseToAnyPublisher() }
                return self.createCoreDataKeyword(requestModel: requestModel)
            }
            .eraseToAnyPublisher()
    }
    
    func deleteNotificationKeyword(requestModel: NoticeKeywordDto) -> AnyPublisher<Void, ErrorResponse> {
        if let id = requestModel.id {
            return networkService.request(api: NoticeListAPI.deleteNotificationKeyword(id))
        }
        else {
            if let existingKeywords = coreDataService.fetchEntities(objectType: NoticeKeywordInformation.self, predicate: NSPredicate(format: "name == %@", requestModel.keyword)) {
                for deletedKeyword in existingKeywords {
                    coreDataService.delete(deletedObject: deletedKeyword)
                }
            }
            return Fail(error: ErrorResponse(code: "", message: "로그인에 실패하여 코어데이터에서 키워드 삭제")).eraseToAnyPublisher()
        }
    }
    
    func fetchMyNotificationKeyword() -> AnyPublisher<NoticeKeywordsFetchResult, ErrorResponse> {
        return networkService.requestWithResponse(api: NoticeListAPI.fetchNotificationKeyword)
            .map { NoticeKeywordsFetchResult.success($0) }
            .catch { [weak self] error -> AnyPublisher<NoticeKeywordsFetchResult, ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                return self.fetchCoreDataKeyword()
            }
            .eraseToAnyPublisher()
    }
    
    func fetchRecommendedKeyword(count: Int?) -> AnyPublisher<NoticeRecommendedKeywordDto, Error> {
        if let count = count {
            let requestModel = FetchRecommendedSearchWordRequest(count: count)
            return networkService.requestWithResponse(api: NoticeListAPI.fetchRecommendedSearchWord(requestModel)).eraseToAnyPublisher()
        }
        else {
            return networkService.requestWithResponse(api: NoticeListAPI.fetchRecommendedKeyword).eraseToAnyPublisher()
        }
    }
    
    func downloadNoticeAttachment(downloadUrl: String, fileName: String) -> AnyPublisher<URL?, ErrorResponse> {
        guard let url = URL(string: downloadUrl) else {
            return Fail(error: ErrorResponse(code: "", message: "URL이 유효하지 않습니다."))
                .eraseToAnyPublisher()
        }
        var api = URLRequest(url: url)
        api.method = .get
        api.headers = ["Content-Type":"multipart/form-data"]
        
        return networkService.downloadFiles(api: api, fileName: fileName)
    }
    
    func manageRecentSearchedWord(name: String, date: Date, actionType: Int) {
        if actionType == 0 {
            let word = RecentSearchedWordInfo(context: coreDataService.context)
            word.name = name
            word.searchedDate = date
            
            coreDataService.insert(insertedObject: word)
        }
        else {
            let predicate = NSPredicate(format: "name == %@ AND searchedDate == %@", name, date as NSDate)
            
            if let existingKeyWords = coreDataService.fetchEntities(objectType: RecentSearchedWordInfo.self, predicate: predicate) {
                for deletedKeyWord in existingKeyWords {
                    coreDataService.delete(deletedObject: deletedKeyWord)
                }
            }
        }
    }
    
    func fetchRecentSearchedWord() -> [RecentSearchedWordInfo] {
        let data = coreDataService.fetchEntities(objectType: RecentSearchedWordInfo.self)
        if let data = data {
            return data.sorted(by: { $0.searchedDate ?? Date() > $1.searchedDate ?? Date()})
        }
        else {
            return []
        }
    }
    
    
    private func fetchCoreDataKeyword() -> AnyPublisher<NoticeKeywordsFetchResult, ErrorResponse> {
        let data = self.coreDataService.fetchEntities(objectType: NoticeKeywordInformation.self)
        var myKeywords: [NoticeKeywordDto] = []
        if let data = data {
            for keyword in data {
                myKeywords.append(NoticeKeywordDto(id: nil, keyword: keyword.name ?? ""))
            }
        }
        let result = NoticeKeywordsDto(keywords: myKeywords)
        return Just(NoticeKeywordsFetchResult.successWithCoreData(result)).setFailureType(to: ErrorResponse.self)
            .eraseToAnyPublisher()
    }
    
    private func createCoreDataKeyword(requestModel: NoticeKeywordDto) -> AnyPublisher<NoticeKeywordDto, ErrorResponse> {
        let keyword = NoticeKeywordInformation(context: self.coreDataService.context)
        keyword.name = requestModel.keyword
        self.coreDataService.insert(insertedObject: keyword)
        return Fail(error: ErrorResponse(code: "", message: "로그인에 실패하여 코어데이터에 키워드 저장")).eraseToAnyPublisher()
    }
}

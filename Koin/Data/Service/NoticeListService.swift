//
//  NoticeListService.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/17/24.
//

import Alamofire
import Combine

protocol NoticeListService {
    func fetchNoticeArticles(requestModel: FetchNoticeArticlesRequest) -> AnyPublisher<NoticeListDTO, Error>
    func searchNoticeArticle(requestModel: SearchNoticeArticleRequest) -> AnyPublisher<NoticeListDTO, Error>
    func fetchNoticeData(requestModel: FetchNoticeDataRequest) -> AnyPublisher<NoticeArticleDTO, Error>
    func fetchHotNoticeArticles() -> AnyPublisher<[NoticeArticleDTO], Error>
    func createNotificationKeyword(requestModel: NoticeKeywordDTO) -> AnyPublisher<NoticeKeywordDTO, ErrorResponse>
    func deleteNotificationKeyword(requestModel: NoticeKeywordDTO) -> AnyPublisher<Void, ErrorResponse>
    func fetchMyNotificationKeyword() -> AnyPublisher<NoticeKeywordsFetchResult, ErrorResponse>
    func fetchRecommendedKeyword(count: Int?) -> AnyPublisher<NoticeRecommendedKeywordDTO, Error>
    func downloadNoticeAttachment(downloadUrl: String, fileName: String) -> AnyPublisher<Void, ErrorResponse>
    func manageRecentSearchedWord(name: String, date: Date, actionType: Int)
    func fetchRecentSearchedWord() -> [RecentSearchedWordInfo]
}

final class DefaultNoticeService: NoticeListService {
    let networkService = NetworkService()
    let coreDataService = CoreDataService.shared
    
    func fetchNoticeArticles(requestModel: FetchNoticeArticlesRequest) -> AnyPublisher<NoticeListDTO, Error> {
        return request(.fetchNoticeArticles(requestModel))
    }
    
    func searchNoticeArticle(requestModel: SearchNoticeArticleRequest) -> AnyPublisher<NoticeListDTO, Error> {
        return request(.searchNoticeArticle(requestModel))
    }
    
    func fetchNoticeData(requestModel: FetchNoticeDataRequest) -> AnyPublisher<NoticeArticleDTO, Error> {
        return request(.fetchNoticeData(requestModel))
    }
    
    func fetchHotNoticeArticles() -> AnyPublisher<[NoticeArticleDTO], Error> {
        return request(.fetchHotNoticeArticles)
    }
    
    func createNotificationKeyword(requestModel: NoticeKeywordDTO) -> AnyPublisher<NoticeKeywordDTO, ErrorResponse> {
        return networkService.requestWithResponse(api: NoticeListAPI.createNotificationKeyword(requestModel))
            .catch { [weak self] error -> AnyPublisher<NoticeKeywordDTO, ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.requestWithResponse(api: NoticeListAPI.createNotificationKeyword(requestModel))
                        }
                        .catch { [weak self] _ -> AnyPublisher<NoticeKeywordDTO, ErrorResponse> in
                            guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                            let keyword = NoticeKeywordInformation(context: self.coreDataService.context)
                            keyword.name = requestModel.keyword
                            self.coreDataService.insert(insertedObject: keyword)
                            return Fail(error: ErrorResponse(code: "", message: "로그인에 실패하여 코어데이터에 키워드 저장")).eraseToAnyPublisher()
                        }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func deleteNotificationKeyword(requestModel: NoticeKeywordDTO) -> AnyPublisher<Void, ErrorResponse> {
        if let id = requestModel.id {
            return networkService.request(api: NoticeListAPI.deleteNotificationKeyword(id))
                .catch { [weak self] error -> AnyPublisher<Void, ErrorResponse> in
                    guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                    if error.code == "401" {
                        return self.networkService.refreshToken()
                            .flatMap { _ in self.networkService.request(api: NoticeListAPI.deleteNotificationKeyword(id))
                            }
                            .eraseToAnyPublisher()
                    } else {
                        return Fail(error: error).eraseToAnyPublisher()
                    }
                }
                .eraseToAnyPublisher()
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
                if error.code == "401" {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.requestWithResponse(api: NoticeListAPI.fetchNotificationKeyword).map { NoticeKeywordsFetchResult.success($0) }
                        }
                        .catch { [weak self] _ -> AnyPublisher<NoticeKeywordsFetchResult, ErrorResponse> in
                            let data = self?.coreDataService.fetchEntities(objectType: NoticeKeywordInformation.self)
                            var myKeywords: [NoticeKeywordDTO] = []
                            if let data = data {
                                for keyword in data {
                                    myKeywords.append(NoticeKeywordDTO(id: nil, keyword: keyword.name ?? ""))
                                }
                            }
                            let result = NoticeKeywordsDTO(keywords: myKeywords)
                            return Just(NoticeKeywordsFetchResult.successWithCoreData(result)).setFailureType(to: ErrorResponse.self)
                                .eraseToAnyPublisher()
                        }.eraseToAnyPublisher()
                } else {
                    return Fail(error: error.self).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func fetchRecommendedKeyword(count: Int?) -> AnyPublisher<NoticeRecommendedKeywordDTO, Error> {
        if let count = count {
            let requestModel = FetchRecommendedSearchWordRequest(count: count)
            return request(.fetchRecommendedSearchWord(requestModel)).eraseToAnyPublisher()
        }
        else {
            return request(.fetchRecommendedKeyword).eraseToAnyPublisher()
        }
    }
    
    func downloadNoticeAttachment(downloadUrl: String, fileName: String) -> AnyPublisher<Void, ErrorResponse> {
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
   
    private func request<T: Decodable>(_ api: NoticeListAPI) -> AnyPublisher<T, Error> {
        return AF.request(api)
            .publishDecodable(type: T.self)
            .value()
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}

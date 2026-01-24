//
//  NoticeListService.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/17/24.
//

import Alamofire
import Combine

protocol NoticeListService {
    func fetchNoticeArticles(requestModel: FetchNoticeArticlesRequest) -> AnyPublisher<NoticeListDto, Error>
    func searchNoticeArticle(requestModel: SearchNoticeArticleRequest) -> AnyPublisher<NoticeListDto, Error>
    func fetchLostItemArticles(requestModel: FetchLostItemsRequest, retry: Bool) -> AnyPublisher<NoticeListDto, Error>
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
    func fetchLostItem(id: Int, retry: Bool) -> AnyPublisher<LostArticleDetailDto, ErrorResponse>
    func deleteLostItem(id: Int) -> AnyPublisher<Void, ErrorResponse>
    func reportLostItemArticle(id: Int, request: ReportLostItemRequest) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultNoticeService: NoticeListService {
        
    let networkService = NetworkService()
    let coreDataService = CoreDataService.shared
    
    func fetchLostItemArticles(requestModel: FetchLostItemsRequest, retry: Bool) -> AnyPublisher<NoticeListDto, Error> {
        return networkService.requestWithResponse(api: NoticeListAPI.fetchLostItemArticles(requestModel))
            .catch { [weak self] error -> AnyPublisher<NoticeListDto, Error> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" && !retry {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.requestWithResponse(api: NoticeListAPI.fetchLostItemArticles(requestModel)) }
                        .catch { refreshError -> AnyPublisher<NoticeListDto, Error> in
                            return self.fetchLostItemArticles(requestModel: requestModel, retry: true)
                        }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    
    func reportLostItemArticle(id: Int, request: ReportLostItemRequest) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: NoticeListAPI.reportLostItem(id, request))
            .catch { [weak self] error -> AnyPublisher<Void, ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.request(api: NoticeListAPI.reportLostItem(id, request)) }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func postLostItem(request: [PostLostItemRequest]) -> AnyPublisher<LostItemDataDto, ErrorResponse> {
        return networkService.requestWithResponse(api: NoticeListAPI.postLostItem(request))
            .catch { [weak self] error -> AnyPublisher<LostItemDataDto, ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.requestWithResponse(api: NoticeListAPI.postLostItem(request)) }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func fetchLostItemList(requestModel: FetchNoticeArticlesRequest) -> AnyPublisher<NoticeListDto, Error> {
        return request(.fetchLostItemList(requestModel))
    }
    func fetchLostItem(id: Int, retry: Bool = false) -> AnyPublisher<LostArticleDetailDto, ErrorResponse> {
        return networkService.requestWithResponse(api: NoticeListAPI.fetchLostItem(id))
            .catch { [weak self] error -> AnyPublisher<LostArticleDetailDto, ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" && !retry {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.requestWithResponse(api: NoticeListAPI.fetchLostItem(id)) }
                        .catch { refreshError -> AnyPublisher<LostArticleDetailDto, ErrorResponse> in
                            return self.fetchLostItem(id: id, retry: true)
                        }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func deleteLostItem(id: Int) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: NoticeListAPI.deleteLostItem(id))
            .catch { [weak self] error -> AnyPublisher<Void, ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.request(api: NoticeListAPI.deleteLostItem(id)) }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func fetchNoticeArticles(requestModel: FetchNoticeArticlesRequest) -> AnyPublisher<NoticeListDto, Error> {
        return request(.fetchNoticeArticles(requestModel))
    }
    
    func searchNoticeArticle(requestModel: SearchNoticeArticleRequest) -> AnyPublisher<NoticeListDto, Error> {
        return request(.searchNoticeArticle(requestModel))
    }
    
    func fetchNoticeData(requestModel: FetchNoticeDataRequest) -> AnyPublisher<NoticeArticleDto, Error> {
        return request(.fetchNoticeData(requestModel))
    }
    
    func fetchHotNoticeArticles() -> AnyPublisher<[NoticeArticleDto], Error> {
        return request(.fetchHotNoticeArticles)
    }
    
    func createNotificationKeyword(requestModel: NoticeKeywordDto) -> AnyPublisher<NoticeKeywordDto, ErrorResponse> {
        return networkService.requestWithResponse(api: NoticeListAPI.createNotificationKeyword(requestModel))
            .catch { [weak self] error -> AnyPublisher<NoticeKeywordDto, ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.requestWithResponse(api: NoticeListAPI.createNotificationKeyword(requestModel))
                        }
                        .catch { [weak self] _ -> AnyPublisher<NoticeKeywordDto, ErrorResponse> in
                            guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                            return self.createCoreDataKeyword(requestModel: requestModel)
                        }
                        .eraseToAnyPublisher()
                } else {
                    return self.createCoreDataKeyword(requestModel: requestModel)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func deleteNotificationKeyword(requestModel: NoticeKeywordDto) -> AnyPublisher<Void, ErrorResponse> {
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
                            guard let self = self else { return Fail(error: error.self).eraseToAnyPublisher() }
                            return self.fetchCoreDataKeyword()
                        }.eraseToAnyPublisher()
                } else {
                    return fetchCoreDataKeyword()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func fetchRecommendedKeyword(count: Int?) -> AnyPublisher<NoticeRecommendedKeywordDto, Error> {
        if let count = count {
            let requestModel = FetchRecommendedSearchWordRequest(count: count)
            return request(.fetchRecommendedSearchWord(requestModel)).eraseToAnyPublisher()
        }
        else {
            return request(.fetchRecommendedKeyword).eraseToAnyPublisher()
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

    private func request<T: Decodable>(_ api: NoticeListAPI) -> AnyPublisher<T, Error> {
        return AF.request(api)
            .publishDecodable(type: T.self)
            .value()
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}

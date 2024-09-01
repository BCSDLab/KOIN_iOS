//
//  NoticeListAPI.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/17/24.
//

import Alamofire

enum NoticeListAPI {
    case fetchNoticeArticles(FetchNoticeArticlesRequest)
    case searchNoticeArticle(SearchNoticeArticleRequest)
    case fetchNoticeData(FetchNoticeDataRequest)
    case fetchHotNoticeArticles
    case createNotificationKeyWord(NoticeKeyWordDTO)
    case deleteNotificationKeyWord(Int)
    case fetchNotificationKeyWord
    case fetchRecommendedSearchWord(Int)
    case fetchRecommendedKeyWord
}

extension NoticeListAPI: Router, URLRequestConvertible {
    
    public var baseURL: String {
        return Bundle.main.baseUrl
    }
    
    public var path: String {
        switch self {
        case .fetchNoticeArticles: return "/articles"
        case .searchNoticeArticle: return "/articles/search"
        case .fetchNoticeData(let request): return "/articles/\(request.noticeId)"
        case .fetchHotNoticeArticles: return "/articles/hot"
        case .createNotificationKeyWord: return "/articles/keyword"
        case .deleteNotificationKeyWord(let request): return "/articles/keyword/\(request)"
        case .fetchRecommendedKeyWord: return "/articles/keyword/suggestions"
        case .fetchRecommendedSearchWord: return "/articles/hot/keyword"
        case .fetchNotificationKeyWord: return "/articles/keyword/me"
        }
    }
    
    public var method: Alamofire.HTTPMethod {
        switch self {
        case .fetchNoticeArticles, .searchNoticeArticle, .fetchNoticeData, .fetchHotNoticeArticles, .fetchNotificationKeyWord, .fetchRecommendedKeyWord, .fetchRecommendedSearchWord:
            return .get
        case .createNotificationKeyWord:
            return .post
        case .deleteNotificationKeyWord:
            return .delete
        }
    }
    
    public var headers: [String: String] {
        switch self {
        case .fetchNoticeArticles, .searchNoticeArticle, .fetchNoticeData, .fetchHotNoticeArticles, .fetchRecommendedKeyWord, .fetchRecommendedSearchWord:
            return [:]
        case .createNotificationKeyWord, .deleteNotificationKeyWord, .fetchNotificationKeyWord:
            if let token = KeyChainWorker.shared.read(key: .access) {
                let headers = ["Authorization": "Bearer \(token)"]
                return headers
            } else {
                return [:]
            }
        }
    }
    
    
    public var parameters: Any? {
        switch self {
        case .fetchNoticeArticles(let request):
            return try? request.toDictionary()
        case .searchNoticeArticle(let request):
            return try? request.toDictionary()
        case .fetchRecommendedSearchWord(let count):
            return try? count.toDictionary()
        case .fetchNoticeData, .fetchHotNoticeArticles, .fetchNotificationKeyWord , .fetchRecommendedKeyWord:
            return nil
        case .createNotificationKeyWord(let request):
            return try? request.toDictionary()
        case .deleteNotificationKeyWord(let request):
            return try? request.toDictionary()
        }
    }
    
    public var encoding: ParameterEncoding? {
        switch self {
        case .fetchNoticeArticles, .searchNoticeArticle, .fetchHotNoticeArticles, .fetchNotificationKeyWord, .fetchRecommendedKeyWord:
            return URLEncoding.default
        case .fetchNoticeData, .fetchRecommendedSearchWord: return URLEncoding.queryString
        case .createNotificationKeyWord, .deleteNotificationKeyWord: return JSONEncoding.default
        }
    }
}

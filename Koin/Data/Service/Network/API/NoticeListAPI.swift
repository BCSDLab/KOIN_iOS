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
    case fetchNotificationKeyWord(Bool)
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
        case .fetchNotificationKeyWord(let isMyKeyWord): return isMyKeyWord ? "/articles/keyword/me" : "/articles/keyword/suggestions"
        }
    }
    
    public var method: Alamofire.HTTPMethod {
        switch self {
        case .fetchNoticeArticles, .searchNoticeArticle, .fetchNoticeData, .fetchHotNoticeArticles, .fetchNotificationKeyWord:
            return .get
        case .createNotificationKeyWord:
            return .post
        case .deleteNotificationKeyWord:
            return .delete
        }
    }
    
    public var headers: [String: String] {
        switch self {
        case .fetchNoticeArticles, .searchNoticeArticle, .fetchNoticeData, .fetchHotNoticeArticles, .fetchNotificationKeyWord(false):
            return [:]
        case .createNotificationKeyWord, .deleteNotificationKeyWord, .fetchNotificationKeyWord(true):
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
        case .fetchNoticeData, .fetchHotNoticeArticles, .fetchNotificationKeyWord:
            return nil
        case .createNotificationKeyWord(let request):
            return try? request.toDictionary()
        case .deleteNotificationKeyWord(let request):
            return try? request.toDictionary()
        }
    }
    
    public var encoding: ParameterEncoding? {
        switch self {
        case .fetchNoticeArticles, .searchNoticeArticle, .fetchHotNoticeArticles, .fetchNotificationKeyWord:
            return URLEncoding.default
        case .fetchNoticeData: return URLEncoding.queryString
        case .createNotificationKeyWord, .deleteNotificationKeyWord: return JSONEncoding.default
        }
    }
}

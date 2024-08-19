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
    case fetchNoticedata(FetchNoticeDataRequest)
    case fetchHotArticles
}

extension NoticeListAPI: Router, URLRequestConvertible {
    
    public var baseURL: String {
        return Bundle.main.baseUrl
    }
    
    public var path: String {
        switch self {
        case .fetchNoticeArticles: return "/articles"
        case .searchNoticeArticle: return "/articles/search"
        case .fetchNoticedata(let request): return "/articles/\(request.noticeId)"
        case .fetchHotArticles: return "/articles/hot"
        }
    }
    
    public var method: Alamofire.HTTPMethod {
        switch self {
        case .fetchNoticeArticles, .searchNoticeArticle, .fetchNoticedata, .fetchHotArticles:
            return .get
        }
    }
    
    public var headers: [String: String] {
        return [:]
    }
    
    
    public var parameters: Any? {
        switch self {
        case .fetchNoticeArticles(let request): 
            return try? request.toDictionary()
        case .searchNoticeArticle(let request):
            return try? request.toDictionary()
        case .fetchNoticedata, .fetchHotArticles:
            return nil
        }
    }
    
    public var encoding: ParameterEncoding? {
        switch self {
        case .fetchNoticeArticles, .searchNoticeArticle, .fetchHotArticles:
            return URLEncoding.default
        case .fetchNoticedata: return URLEncoding.queryString
        }
    }
 
}

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
}

extension NoticeListAPI: Router, URLRequestConvertible {
    
    public var baseURL: String {
        return Bundle.main.baseUrl
    }
    
    public var path: String {
        switch self {
        case .fetchNoticeArticles: return "/articles"
        case .searchNoticeArticle: return "/articles/search"
        }
    }
    
    public var method: Alamofire.HTTPMethod {
        switch self {
        case .fetchNoticeArticles: return .get
        case .searchNoticeArticle: return .get
        }
    }
    
    public var headers: [String: String] {
        switch self {
        case .fetchNoticeArticles: return [:]
        case .searchNoticeArticle: return [:]
        }
    }
    
    
    public var parameters: Any? {
        switch self {
        case .fetchNoticeArticles(let request): 
            return try? request.toDictionary()
        case .searchNoticeArticle(let request):
            return try? request.toDictionary()
        }
    }
    
    public var encoding: ParameterEncoding? {
        switch self {
        case .fetchNoticeArticles: return URLEncoding.default
        case .searchNoticeArticle: return URLEncoding.default
        }
    }
 
}

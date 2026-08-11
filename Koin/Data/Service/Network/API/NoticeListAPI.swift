//
//  NoticeListAPI.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/17/24.
//

import Foundation
import Alamofire

enum NoticeListAPI {
    case fetchNoticeArticles(FetchNoticeArticlesRequest)
    case searchNoticeArticle(SearchNoticeArticleRequest)
    case fetchNoticeData(FetchNoticeDataRequest)
    case fetchHotNoticeArticles
    case createNotificationKeyword(NoticeKeywordDto)
    case deleteNotificationKeyword(Int)
    case fetchNotificationKeyword
    case fetchRecommendedSearchWord(FetchRecommendedSearchWordRequest)
    case fetchRecommendedKeyword
    case postLostItem([PostLostItemRequest])
    case reportLostItem(Int, ReportLostItemRequest)
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
        case .createNotificationKeyword: return "/articles/keyword?type=KOREATECH"
        case .deleteNotificationKeyword(let request): return "/articles/keyword/\(request)"
        case .fetchRecommendedKeyword: return "/articles/keyword/suggestions?type=KOREATECH"
        case .fetchRecommendedSearchWord: return "/articles/hot/keyword"
        case .fetchNotificationKeyword: return "/articles/keyword/me?type=KOREATECH"
        case .postLostItem: return "/articles/lost-item"
        case .reportLostItem(let id, _): return "/articles/lost-item/\(id)/reports"
        }
    }
    
    public var method: Alamofire.HTTPMethod {
        switch self {
        case .fetchNoticeArticles, .searchNoticeArticle, .fetchNoticeData, .fetchHotNoticeArticles, .fetchNotificationKeyword, .fetchRecommendedKeyword, .fetchRecommendedSearchWord:
            return .get
        case .createNotificationKeyword, .postLostItem, .reportLostItem:
            return .post
        case .deleteNotificationKeyword:
            return .delete
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
        case .fetchRecommendedSearchWord(let requestModel):
            return try? requestModel.toDictionary()
        case .fetchNoticeData, .fetchHotNoticeArticles, .fetchNotificationKeyword , .fetchRecommendedKeyword:
            return nil
        case .createNotificationKeyword(let request):
            return try? request.toDictionary()
        case .deleteNotificationKeyword(let request):
            return try? request.toDictionary()
        case .postLostItem(let request):
            return try? PostLostItemRequestWrapper(articles: request).toDictionary()
        case .reportLostItem(_,let request):
            return try? request.toDictionary()
        }
    }
    
    public var encoding: ParameterEncoding? {
        switch self {
        case .fetchNoticeArticles, .searchNoticeArticle, .fetchHotNoticeArticles, .fetchNotificationKeyword, .fetchRecommendedKeyword:
            return URLEncoding.default
        case .fetchNoticeData, .fetchRecommendedSearchWord:
            return URLEncoding.queryString
        case .createNotificationKeyword, .deleteNotificationKeyword, .postLostItem, .reportLostItem: return JSONEncoding.default
        }
    }
    
}

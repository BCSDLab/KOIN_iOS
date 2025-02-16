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
    case createNotificationKeyword(NoticeKeywordDTO)
    case deleteNotificationKeyword(Int)
    case fetchNotificationKeyword
    case fetchRecommendedSearchWord(FetchRecommendedSearchWordRequest)
    case fetchRecommendedKeyword
    case postLostItem([PostLostArticleRequest])
    case fetchLostItemList(FetchNoticeArticlesRequest)
    case fetchLostItem(Int)
    case deleteLostItem(Int)
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
        case .createNotificationKeyword: return "/articles/keyword"
        case .deleteNotificationKeyword(let request): return "/articles/keyword/\(request)"
        case .fetchRecommendedKeyword: return "/articles/keyword/suggestions"
        case .fetchRecommendedSearchWord: return "/articles/hot/keyword"
        case .fetchNotificationKeyword: return "/articles/keyword/me"
        case .postLostItem: return "/articles/lost-item"
        case .fetchLostItemList: return "/articles/lost-item"
        case .fetchLostItem(let id): return "/articles/lost-item/\(id)"
        case .deleteLostItem(let id): return "/articles/lost-item/\(id)"
        }
    }
    
    public var method: Alamofire.HTTPMethod {
        switch self {
        case .fetchNoticeArticles, .searchNoticeArticle, .fetchNoticeData, .fetchHotNoticeArticles, .fetchNotificationKeyword, .fetchRecommendedKeyword, .fetchRecommendedSearchWord, .fetchLostItem, .fetchLostItemList:
            return .get
        case .createNotificationKeyword, .postLostItem:
            return .post
        case .deleteNotificationKeyword, .deleteLostItem:
            return .delete
        }
    }
    
    public var headers: [String: String] {
        switch self {
        case .fetchNoticeArticles, .searchNoticeArticle, .fetchNoticeData, .fetchHotNoticeArticles, .fetchRecommendedKeyword, .fetchRecommendedSearchWord, .fetchLostItemList:
            return [:]
        case .createNotificationKeyword, .deleteNotificationKeyword, .fetchNotificationKeyword, .postLostItem, .deleteLostItem, .fetchLostItem:
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
        case .fetchRecommendedSearchWord(let requestModel):
            return try? requestModel.toDictionary()
        case .fetchNoticeData, .fetchHotNoticeArticles, .fetchNotificationKeyword , .fetchRecommendedKeyword:
            return nil
        case .createNotificationKeyword(let request):
            return try? request.toDictionary()
        case .deleteNotificationKeyword(let request):
            return try? request.toDictionary()
        case .postLostItem(let request):
            return try? PostLostArticleRequestWrapper(articles: request).toDictionary()
        case .fetchLostItemList(let request):
            return try? request.toDictionary()
        case .fetchLostItem:
            return nil
        case .deleteLostItem:
            return nil
        }
    }
    
    public var encoding: ParameterEncoding? {
        switch self {
        case .fetchNoticeArticles, .searchNoticeArticle, .fetchHotNoticeArticles, .fetchNotificationKeyword, .fetchRecommendedKeyword, .fetchLostItemList, .fetchLostItem, .deleteLostItem:
            return URLEncoding.default
        case .fetchNoticeData, .fetchRecommendedSearchWord: 
            return URLEncoding.queryString
        case .createNotificationKeyword, .deleteNotificationKeyword, .postLostItem: return JSONEncoding.default
        }
    }
}

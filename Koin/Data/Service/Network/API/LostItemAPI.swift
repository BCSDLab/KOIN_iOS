//
//  LostItemAPI.swift
//  koin
//
//  Created by 홍기정 on 1/21/26.
//

import Foundation
import Alamofire

enum LostItemAPI {
    case fetchLostItemList(FetchLostItemListRequest)
    case fetchLostItemData(Int)
    case changeListItemState(Int)
    case deleteLostItem(Int)
    case updateLostItem((Int, UpdateLostItemRequest))
    case fetchLostItemStats
    
    case subscribeKeyword(SubscribeKeywordRequest)
    case fetchKeywordSuggestion
    case fetchMyKeyword
    case unsubscribeKeyword(Int)
}

extension LostItemAPI: Router, URLRequestConvertible {
    public var baseURL: String {
        return Bundle.main.baseUrl
    }
    
    public var path: String {
        switch self {
        case .fetchLostItemList: return "/articles/lost-item/v2"
        case .fetchLostItemData(let id): return "/articles/lost-item/v2/\(id)"
        case .changeListItemState(let id): return "/articles/lost-item/\(id)/found"
        case .deleteLostItem(let id): return "/articles/lost-item/\(id)"
        case .updateLostItem((let id, _)): return "/articles/lost-item/\(id)"
        case .fetchLostItemStats: return "/articles/lost-item/stats"
            
        case .subscribeKeyword: return "/articles/keyword?type=LOST_ITEM"
        case .fetchKeywordSuggestion: return "/articles/keyword/suggestions?type=LOST_ITEM"
        case .fetchMyKeyword: return "/articles/keyword/me?type=LOST_ITEM"
        case .unsubscribeKeyword(let id): return "/articles/keyword/\(id)"
        }
    }
    
    public var method: Alamofire.HTTPMethod {
        switch self {
        case .fetchLostItemList: return .get
        case .fetchLostItemData: return .get
        case .changeListItemState: return .post
        case .deleteLostItem: return .delete
        case .updateLostItem: return .put
        case .fetchLostItemStats: return .get
            
        case .subscribeKeyword: return .post
        case .fetchKeywordSuggestion: return .get
        case .fetchMyKeyword: return .get
        case .unsubscribeKeyword: return .delete
        }
    }
    
    public var headers: [String: String] {
        return [:]
    }
    
    public var parameters: Any? {
        switch self {
        case .fetchLostItemList(let request): return try? request.toDictionary()
        case .fetchLostItemData: return nil
        case .changeListItemState: return nil
        case .deleteLostItem: return nil
        case .updateLostItem((_, let request)): return try? request.toDictionary()
        case .fetchLostItemStats: return nil
            
        case .subscribeKeyword(let request):
            return try? request.toDictionary()
        case .fetchKeywordSuggestion, .fetchMyKeyword, .unsubscribeKeyword:
            return nil
        }
    }
    
    public var encoding: ParameterEncoding? {
        switch self {
        case .fetchLostItemList: return URLEncoding(arrayEncoding: .noBrackets)
        case .fetchLostItemData: return URLEncoding.default
        case .changeListItemState: return URLEncoding.default
        case .deleteLostItem: return URLEncoding.default
        case .updateLostItem: return JSONEncoding.default
        case .fetchLostItemStats: return nil
            
        case .subscribeKeyword:
            return JSONEncoding.default
        case .fetchKeywordSuggestion, .fetchMyKeyword, .unsubscribeKeyword:
            return nil
        }
    }
}

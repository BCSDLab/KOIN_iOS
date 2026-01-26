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
        }
    }
    
    public var headers: [String: String] {
        switch self {
        case .fetchLostItemList, .fetchLostItemData, .changeListItemState, .deleteLostItem, .updateLostItem:
            if let token = KeychainWorker.shared.read(key: .access) {
                let headers = ["Authorization": "Bearer \(token)"]
                return headers
            } else {
                return [:]
            }
        case .fetchLostItemStats:
            return [:]
        }
    }
    
    public var parameters: Any? {
        switch self {
        case .fetchLostItemList(let request): return try? request.toDictionary()
        case .fetchLostItemData: return nil
        case .changeListItemState: return nil
        case .deleteLostItem: return nil
        case .updateLostItem((_, let request)): return try? request.toDictionary()
        case .fetchLostItemStats: return nil
        }
    }
    
    public var encoding: ParameterEncoding? {
        switch self {
        case .fetchLostItemList: return URLEncoding.default
        case .fetchLostItemData: return URLEncoding.default
        case .changeListItemState: return URLEncoding.default
        case .deleteLostItem: return URLEncoding.default
        case .updateLostItem: return JSONEncoding.default
        case .fetchLostItemStats: return nil
        }
    }
}

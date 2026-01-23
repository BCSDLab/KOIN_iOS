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
}

extension LostItemAPI: Router, URLRequestConvertible {
    public var baseURL: String {
        return Bundle.main.baseUrl
    }
    
    public var path: String {
        switch self {
        case .fetchLostItemList: return "/articles/lost-item/v2"
        case .fetchLostItemData(let id): return "/articles/lost-item/\(id)"
        case .changeListItemState(let id): return "/articles/lost-item/\(id)/found"
        }
    }
    
    public var method: Alamofire.HTTPMethod {
        switch self {
        case .fetchLostItemList, .fetchLostItemData: return .get
        case .changeListItemState: return .post
        }
    }
    
    public var headers: [String: String] {
        switch self {
        case .fetchLostItemList, .fetchLostItemData, .changeListItemState:
            if let token = KeychainWorker.shared.read(key: .access) {
                let headers = ["Authorization": "Bearer \(token)"]
                return headers
            } else {
                return [:]
            }
        }
    }
    
    public var parameters: Any? {
        switch self {
        case .fetchLostItemList(let request): return try? request.toDictionary()
        case .fetchLostItemData, .changeListItemState: return nil
        }
    }
    
    public var encoding: ParameterEncoding? {
        switch self {
        case .fetchLostItemList: return URLEncoding.default
        case .fetchLostItemData, .changeListItemState: return URLEncoding.queryString
        }
    }
}

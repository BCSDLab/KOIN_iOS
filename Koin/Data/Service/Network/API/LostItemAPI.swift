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
}

extension LostItemAPI: Router, URLRequestConvertible {
    public var baseURL: String {
        return Bundle.main.baseUrl
    }
    
    public var path: String {
        switch self {
        case .fetchLostItemList: return "/articles/lost-item/v2"
        }
    }
    
    public var method: Alamofire.HTTPMethod {
        switch self {
        case .fetchLostItemList: return .get
        }
    }
    
    public var headers: [String: String] {
        switch self {
        case .fetchLostItemList:
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
        }
    }
    
    public var encoding: ParameterEncoding? {
        return URLEncoding.default
    }
}

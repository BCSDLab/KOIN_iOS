//
//  DiningAPI.swift
//  koin
//
//  Created by 김나훈 on 6/7/24.
//

import Foundation
import Alamofire

enum DiningAPI {
    case fetchDiningList(FetchDiningListRequest)
    case fetchCoopShopList
}

extension DiningAPI: Router, URLRequestConvertible {
    
    public var baseURL: String {
        return Bundle.main.baseUrl
    }
    
    public var path: String {
        switch self {
        case .fetchDiningList: return "/dinings"
        case .fetchCoopShopList: return "/coopshop/1"
        }
    }
    
    public var method: Alamofire.HTTPMethod {
        switch self {
        case .fetchDiningList, .fetchCoopShopList:
            return .get
        }
    }
    
    public var headers: [String: String] {
        return [:]
    }
    
    public var parameters: Any? {
        switch self {
        case .fetchDiningList(let request): return try? request.toDictionary()
        case .fetchCoopShopList: return nil
        }
    }
    
    public var encoding: ParameterEncoding? {
        switch self {
        case .fetchDiningList, .fetchCoopShopList:
            return URLEncoding.default
        }
    }
}


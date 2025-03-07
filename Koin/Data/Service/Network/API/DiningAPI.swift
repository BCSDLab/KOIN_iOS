//
//  DiningAPI.swift
//  koin
//
//  Created by 김나훈 on 6/7/24.
//

import Alamofire

enum DiningAPI {
    case fetchDiningList(FetchDiningListRequest)
    case fetchCoopShopList
    case diningLike(DiningLikeRequest, Bool)
}

extension DiningAPI: Router, URLRequestConvertible {
    
    public var baseURL: String {
        return Bundle.main.baseUrl
    }
    
    public var path: String {
        switch self {
        case .fetchDiningList: return "/dinings"
        case .fetchCoopShopList: return "/coopshop/1"
        case let .diningLike(_, isLiked): return isLiked ? "/dining/like/cancel" : "/dining/like"
        }
    }
    
    public var method: Alamofire.HTTPMethod {
        switch self {
        case .fetchDiningList, .fetchCoopShopList:
            return .get
        case .diningLike:
            return .patch
        }
    }
    
    public var headers: [String: String] {
        switch self {
        case .fetchCoopShopList: return [:]
        case .diningLike, .fetchDiningList: 
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
        case .fetchDiningList(let request): return try? request.toDictionary()
        case .fetchCoopShopList: return nil
        case let .diningLike(request, _): return try? request.toDictionary()
        }
    }
    
    public var encoding: ParameterEncoding? {
        switch self {
        case .fetchDiningList, .fetchCoopShopList:
            return URLEncoding.default
        case .diningLike:
            return URLEncoding.queryString
        }
    }
}


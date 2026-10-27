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
    case reportSoldout(diningId: Int, request: ReportSoldoutRequestDto)
}

extension DiningAPI: Router, URLRequestConvertible {
    
    public var baseURL: String {
        return Bundle.main.baseUrl
    }
    
    public var path: String {
        switch self {
        case .fetchDiningList: return "/dinings"
        case .fetchCoopShopList: return "/coopshop/1"
        case .reportSoldout(let diningId, _): return "/dinings/\(diningId)/soldout-reports"
        }
    }
    
    public var method: Alamofire.HTTPMethod {
        switch self {
        case .fetchDiningList, .fetchCoopShopList:
            return .get
        case .reportSoldout:
            return .post
        }
    }
    
    public var headers: [String: String] {
        return [:]
    }
    
    public var parameters: Any? {
        switch self {
        case .fetchDiningList(let request): return try? request.toDictionary()
        case .fetchCoopShopList: return nil
        case .reportSoldout(_, let request): return try? request.toDictionary()
        }
    }
    
    public var encoding: ParameterEncoding? {
        switch self {
        case .fetchDiningList, .fetchCoopShopList:
            return URLEncoding.default
        case .reportSoldout:
            return JSONEncoding.default
        }
    }
}


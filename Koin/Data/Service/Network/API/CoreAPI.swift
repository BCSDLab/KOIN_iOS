//
//  CoreAPI.swift
//  koin
//
//  Created by 김나훈 on 10/1/24.
//

import Alamofire

enum CoreAPI {
    case checkVersion
    case fetchBanner
}

extension CoreAPI: Router, URLRequestConvertible {
    
    public var baseURL: String {
        return Bundle.main.baseUrl
    }
    
    public var path: String {
        switch self {
        case .checkVersion: return "/version/ios"
        case .fetchBanner: return "/banners/1"
        }
    }
    
    public var method: Alamofire.HTTPMethod {
        switch self {
        case .checkVersion, .fetchBanner: return .get
        }
    }
    
    public var headers: [String: String] {
        switch self {
        case .checkVersion, .fetchBanner: return [:]
        }
    }
    
    
    public var parameters: Any? {
        switch self {
        case .checkVersion:
            return nil
        case .fetchBanner:
            return ["platform": "IOS"]
        }
    }
    
    public var encoding: ParameterEncoding? {
        switch self {
        case .checkVersion: return URLEncoding.default
        case .fetchBanner: return URLEncoding.default
        }
    }
 
}

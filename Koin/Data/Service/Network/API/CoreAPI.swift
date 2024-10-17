//
//  CoreAPI.swift
//  koin
//
//  Created by 김나훈 on 10/1/24.
//

import Alamofire

enum CoreAPI {
    case checkVersion
}

extension CoreAPI: Router, URLRequestConvertible {
    
    public var baseURL: String {
        return Bundle.main.baseUrl
    }
    
    public var path: String {
        switch self {
        case .checkVersion: return "/version/ios"
        }
    }
    
    public var method: Alamofire.HTTPMethod {
        switch self {
        case .checkVersion: return .get
        }
    }
    
    public var headers: [String: String] {
        switch self {
        case .checkVersion: return [:]
        }
    }
    
    
    public var parameters: Any? {
        switch self {
        case .checkVersion:
            return nil
        }
    }
    
    public var encoding: ParameterEncoding? {
        switch self {
        case .checkVersion: return URLEncoding.default
        }
    }
 
}

//
//  AbTestAPI.swift
//  koin
//
//  Created by 김나훈 on 9/23/24.
//

import Alamofire

enum AbTestAPI {
    case assignAbTest(AssignAbTestRequest)
}

extension AbTestAPI: Router, URLRequestConvertible {
    
    public var baseURL: String {
        return Bundle.main.baseUrl
    }
    
    public var path: String {
        switch self {
        case .assignAbTest: return "/abtest/assign"
        }
    }
    
    public var method: Alamofire.HTTPMethod {
        switch self {
        case .assignAbTest: return .post
        }
    }
    
    public var headers: [String: String] {
        var defaultHeaders = ["Content-Type": "application/json"]
        if let accessHistoryId = KeyChainWorker.shared.read(key: .accessHistoryId) {
            defaultHeaders["access_history_id"] = accessHistoryId
        }
        
        return defaultHeaders
    }
    
    public var parameters: Any? {
        switch self {
        case .assignAbTest(let request):
            return try? request.toDictionary()
        }
    }
    public var encoding: ParameterEncoding? {
        switch self {
        case .assignAbTest: return JSONEncoding.default
        }
    }
    
}

//
//  AbTestAPI.swift
//  koin
//
//  Created by 김나훈 on 9/23/24.
//

import Alamofire

enum AbTestAPI {
    case assignAbTest(AssignAbTestRequest)
    case assignAbTestToken
}

extension AbTestAPI: Router, URLRequestConvertible {
    
    public var baseURL: String {
        return Bundle.main.baseUrl
    }
    
    public var path: String {
        switch self {
        case .assignAbTest: return "/abtest/assign"
        case .assignAbTestToken: return "/abtest/assign/token"
        }
    }
    
    public var method: Alamofire.HTTPMethod {
        switch self {
        case .assignAbTest, .assignAbTestToken: return .post
        }
    }
    
    public var headers: [String: String] {
        switch self {
        case .assignAbTest:
            var defaultHeaders = ["Content-Type": "application/json"]
            if let accessHistoryId = KeychainWorker.shared.read(key: .accessHistoryId) {
                defaultHeaders["access_history_id"] = accessHistoryId
            }
            if let token = KeychainWorker.shared.read(key: .access) {
                defaultHeaders["Authorization"] = "Bearer \(token)"
            }
            return defaultHeaders
        case .assignAbTestToken:
            return [:]
        }
    }
    
    public var parameters: Any? {
        switch self {
        case .assignAbTest(let request):
            return try? request.toDictionary()
        case .assignAbTestToken:
            return nil
        }
    }
    public var encoding: ParameterEncoding? {
        switch self {
        case .assignAbTest: return JSONEncoding.default
        case .assignAbTestToken: return nil
        }
    }
    
    
}

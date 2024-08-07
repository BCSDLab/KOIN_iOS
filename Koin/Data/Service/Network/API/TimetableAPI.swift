//
//  TimetableAPI.swift
//  koin
//
//  Created by 김나훈 on 7/22/24.
//

import Alamofire

enum TimetableAPI {
    case fetchDeptList
}

extension TimetableAPI: Router, URLRequestConvertible {
    
    public var baseURL: String {
        return Bundle.main.baseUrl
    }
    
    public var path: String {
        switch self {
        case .fetchDeptList: return "/depts"
        }
    }
    
    public var method: Alamofire.HTTPMethod {
        switch self {
        case .fetchDeptList: return .get
        }
    }
    
    public var headers: [String: String] {
        switch self {
        case .fetchDeptList: return [:]
        }
    }
    
    
    public var parameters: Any? {
        switch self {
        case .fetchDeptList: return nil
        }
    }
    
    public var encoding: ParameterEncoding? {
        switch self {
        case .fetchDeptList: return URLEncoding.default
        }
    }
 
}

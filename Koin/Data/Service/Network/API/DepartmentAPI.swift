//
//  DepartmentAPI.swift
//  koin
//
//  Created by 홍기정 on 6/6/26.
//

import Foundation
import Alamofire

enum DepartmentAPI {
    case fetchDepartment(FetchDepartmentRequestDto)
}

extension DepartmentAPI: Router, URLRequestConvertible {
    
    public var baseURL: String {
        return Bundle.main.baseUrl
    }
    
    public var path: String {
        switch self {
        case .fetchDepartment: return "/department-contacts"
        }
    }
    
    public var method: Alamofire.HTTPMethod {
        switch self {
        case .fetchDepartment: .get
        }
    }
    
    public var headers: [String: String] {
        var baseHeaders: [String: String] = [:]
        switch self {
        case .fetchDepartment: break
        }
        return baseHeaders
    }
    
    
    public var parameters: Any? {
        switch self {
        case .fetchDepartment(let keyword):
            return try? keyword.toDictionary()
        }
    }
    
    public var encoding: ParameterEncoding? {
        switch self {
        case .fetchDepartment: return URLEncoding.default
        }
    }
 
}

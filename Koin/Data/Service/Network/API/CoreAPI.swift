//
//  CoreAPI.swift
//  koin
//
//  Created by 김나훈 on 10/1/24.
//

import Foundation
import Alamofire

enum CoreAPI {
    case checkVersion
    case fetchBanner
    case fetchClubCategories
    case fetchHotClubs
    case uploadFiles([Data], String)
}

extension CoreAPI: Router, URLRequestConvertible {
    
    public var baseURL: String {
        return Bundle.main.baseUrl
    }
    
    public var path: String {
        switch self {
        case .checkVersion: return "/version/ios"
        case .fetchBanner: return "/banners/1"
        case .fetchClubCategories: return "/clubs/categories"
        case .fetchHotClubs: return "/clubs/hot"
        case .uploadFiles(_, let domain): return "/\(domain)/upload/files"
        }
    }
    
    public var method: Alamofire.HTTPMethod {
        switch self {
        case .checkVersion, .fetchBanner, .fetchClubCategories, .fetchHotClubs: return .get
        case .uploadFiles: return .post
        }
    }
    
    public var headers: [String: String] {
        var baseHeaders: [String: String] = [:]
        switch self {
        case .checkVersion, .fetchBanner, .fetchClubCategories, .fetchHotClubs: return [:]
        case .uploadFiles:
            baseHeaders["Content-Type"] = "multipart/form-data"
        }
        return baseHeaders
    }
    
    
    public var parameters: Any? {
        switch self {
        case .checkVersion:
            return nil
        case .fetchClubCategories:
            return nil
        case .fetchHotClubs:
            return nil
        case .fetchBanner:
            return ["platform": "IOS"]
        case .uploadFiles:
            return nil
        }
    }
    
    public var encoding: ParameterEncoding? {
        switch self {
        case .checkVersion: return URLEncoding.default
        case .fetchBanner: return URLEncoding.default
        case .fetchClubCategories: return URLEncoding.default
        case .fetchHotClubs: return URLEncoding.default
        case .uploadFiles: return URLEncoding.default
        }
    }
 
}

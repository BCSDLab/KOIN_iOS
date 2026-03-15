//
//  CallVanAPI.swift
//  koin
//
//  Created by 홍기정 on 3/15/26.
//

import Foundation
import Alamofire

enum CallVanAPI {
    case fetchCallVanList(CallVanListRequestDto)
    case fetchNotification
}

extension CallVanAPI: Router, URLRequestConvertible {
    
    public var baseURL: String {
        return Bundle.main.baseUrl
    }
    
    public var path: String {
        switch self {
        case .fetchCallVanList: return "/callvan"
        case .fetchNotification: return "/callvan/notifications"
        }
    }
    
    public var method: Alamofire.HTTPMethod {
        switch self {
        case .fetchCallVanList: return .get
        case .fetchNotification: return .get
        }
    }
    
    public var headers: [String: String] {
        switch self {
        case .fetchCallVanList, .fetchNotification:
            return [:]
        }
    }
    
    public var parameters: Any? {
        switch self {
        case .fetchCallVanList(let request):
            return try? request.toDictionary()
        case .fetchNotification:
            return nil
        }
    }
    public var encoding: ParameterEncoding? {
        switch self {
        case .fetchCallVanList:
            return URLEncoding(arrayEncoding: .noBrackets)
        case .fetchNotification:
            return nil
        }
    }
    
    
}

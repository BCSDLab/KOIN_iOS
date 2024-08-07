//
//  LandAPI.swift
//  koin
//
//  Created by 김나훈 on 6/23/24.
//

import Alamofire

enum LandAPI {
    case fetchLandList
    case fetchLandDetail(FetchLandDetailRequest)
}

extension LandAPI: Router, URLRequestConvertible {
    
    public var baseURL: String {
        return Bundle.main.baseUrl
    }
    
    public var path: String {
        switch self {
        case .fetchLandList: return "/lands"
        case .fetchLandDetail(let request): return "/lands/\(request.id)"
        }
    }
    
    public var method: Alamofire.HTTPMethod {
        return .get
    }
    
    public var headers: [String: String] {
        return [:]
    }
    
    public var parameters: Any? {
        switch self {
        case .fetchLandList: return nil
        case .fetchLandDetail(let request): return try? request.toDictionary()
        }
    }
    
    public var encoding: ParameterEncoding? {
        return URLEncoding.default
    }
}

//
//  HomeAPI.swift
//  koin
//
//  Created by 홍기정 on 6/6/26.
//

import Foundation
import Alamofire

enum HomeAPI {
    case fetchWeather
}

extension HomeAPI: Router, URLRequestConvertible {
    
    public var baseURL: String {
        return Bundle.main.baseUrl
    }
    
    public var path: String {
        switch self {
        case .fetchWeather: return "/weather"
        }
    }
    
    public var method: Alamofire.HTTPMethod {
        switch self {
        case .fetchWeather: .get
        }
    }
    
    public var headers: [String: String] {
        var baseHeaders: [String: String] = [:]
        switch self {
        case .fetchWeather: break
        }
        return baseHeaders
    }
    
    
    public var parameters: Any? {
        switch self {
        case .fetchWeather:
            return nil
        }
    }
    
    public var encoding: ParameterEncoding? {
        switch self {
        case .fetchWeather: return nil
        }
    }
 
}

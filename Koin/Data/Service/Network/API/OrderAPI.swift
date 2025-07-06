//
//  OrderAPI.swift
//  koin
//
//  Created by 이은지 on 7/7/25.
//

import Alamofire

enum OrderAPI {
    case fetchOrderShopList(FetchOrderShopListRequest)
}

extension OrderAPI: Router, URLRequestConvertible {
    
    
    
    public var baseURL: String {
        return Bundle.main.baseUrl
    }
    
    public var path: String {
        switch self {
        case .fetchOrderShopList: return "/order/shops"
        }
    }
    
    public var method: Alamofire.HTTPMethod {
        switch self {
        default: .get
        }
    }
    
    public var headers: [String: String] {
        var baseHeaders: [String: String] = [:]
        switch self {
        case .fetchOrderShopList: break
        default:
            if let token = KeychainWorker.shared.read(key: .access) {
                baseHeaders["Authorization"] = "Bearer \(token)"
            }
        }
        return baseHeaders
    }
    
    public var parameters: Any? {
        switch self {
        case .fetchOrderShopList(let request):
            var parameters: [String: Any] = ["sorter": request.sorter.rawValue]
            for filterItem in request.filter {
                parameters["filter"] = filterItem.rawValue
            }
            return parameters
        }
    }
    
    public var encoding: ParameterEncoding? {
        switch self {
        case .fetchOrderShopList:
            return URLEncoding.default
        default:
            return URLEncoding.default
        }
    }
    
}


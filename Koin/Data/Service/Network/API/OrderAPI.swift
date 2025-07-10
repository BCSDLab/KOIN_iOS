//
//  OrderAPI.swift
//  koin
//
//  Created by 이은지 on 7/7/25.
//

import Alamofire

enum OrderAPI {
    case fetchOrderShopList(FetchOrderShopListRequest)
    case searchShop(String)
}

extension OrderAPI: Router, URLRequestConvertible {
    
    public var baseURL: String {
        return Bundle.main.baseUrl
    }
    
    public var path: String {
        switch self {
        case .fetchOrderShopList: return "/order/shops"
        case .searchShop(let text): return "/shops/search/related/\(text)"
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
        case .fetchOrderShopList:
            if let token = KeychainWorker.shared.read(key: .access) {
                baseHeaders["Authorization"] = "Bearer \(token)"
            }
        case .searchShop:
            break
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
        case .searchShop:
            return nil
        }
    }
    
    public var encoding: ParameterEncoding? {
        switch self {
        case .fetchOrderShopList, .searchShop:
            return URLEncoding.default
        default:
            return URLEncoding.default
        }
    }
}


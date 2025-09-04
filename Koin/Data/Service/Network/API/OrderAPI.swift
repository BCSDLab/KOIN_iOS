//
//  OrderAPI.swift
//  koin
//
//  Created by 이은지 on 7/7/25.
//

import Alamofire

enum OrderAPI {
    case fetchOrderShopList(FetchOrderShopListRequest)
    case fetchOrderEventShop
    case searchShop(String)
}

extension OrderAPI: Router, URLRequestConvertible {
    
    public var baseURL: String {
        return Bundle.main.baseUrl
    }
    
    public var path: String {
        switch self {
        case .fetchOrderShopList: return "/order/shops"
        case .fetchOrderEventShop: return "/order/shops/events"
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
        default:
            break
        }
        return baseHeaders
    }
    
    public var parameters: Any? {
        switch self {
        case .fetchOrderShopList(let request):
            var parameters: [String: Any] = [
                "sorter": request.sorter.rawValue
            ]
            if !request.filter.isEmpty {
                parameters["filter"] = request.filter.map { $0.rawValue }
            }
            if let minimumOrderAmount = request.minimumOrderAmount {
                parameters["minimum_order_amount"] = minimumOrderAmount
            }
            if let categoryFilter = request.categoryFilter {
                parameters["category_filter"] = categoryFilter
            }
            return parameters
        default:
            return nil
        }
    }
    
    public var encoding: ParameterEncoding? {
        switch self {
        case .fetchOrderShopList:
            return URLEncoding(arrayEncoding: .noBrackets)
        default:
            return URLEncoding.default
        }
    }
}


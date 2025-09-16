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
    case fetchOrderShopMenusGroups(orderableShopId: Int)
    case fetchOrderShopMenus(orderableShopId: Int)
    case fetchOrderShopSummary(orderableShopId: Int)
    case fetchOrderInProgress
    case fetchCartSummary(orderableShopId: Int)
    case fetchCartItemsCount
    case resetCart
    case fetchCart(parameter: String)
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
        case .fetchOrderShopMenusGroups(let orderableShopId): return "/order/shop/\(orderableShopId)/menus/groups"
        case .fetchOrderShopMenus(let orderableShopId): return "/order/shop/\(orderableShopId)/menus"
        case .fetchOrderShopSummary(let orderableShopId): return "/order/shop/\(orderableShopId)/summary"
        case .fetchOrderInProgress: return "/order/in-progress"
        case .fetchCartSummary(let orderableShopId): return "/cart/summary/\(orderableShopId)"
        case .fetchCartItemsCount: return "/cart/items/count"
        case .resetCart: return "/cart/reset"
        case .fetchCart: return "/cart"
        }
    }
    
    public var method: Alamofire.HTTPMethod {
        switch self {
        case .resetCart: .delete
        default: .get
        }
    }
    
    public var headers: [String: String] {
        var baseHeaders: [String: String] = [:]
        switch self {
        case .fetchOrderShopList, .fetchOrderInProgress, .fetchCartSummary, .fetchCartItemsCount, .resetCart, .fetchCart:
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
        case .fetchCart(let parameter):
            return ["type" : parameter]
        default:
            return nil
        }
    }
    
    public var encoding: ParameterEncoding? {
        switch self {
        case .fetchOrderShopList:
            return URLEncoding(arrayEncoding: .noBrackets)
        case .resetCart:
            return nil
        default:
            return URLEncoding.default
        }
    }
}


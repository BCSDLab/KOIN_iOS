//
//  ShopAPI.swift
//  koin
//
//  Created by 김나훈 on 5/22/24.
//

import Alamofire

enum ShopAPI {
    case fetchShopList
    case fetchEventList
    case fetchShopCategoryList
    case fetchShopData(FetchShopInfoRequest)
    case fetchShopMenuList(FetchShopInfoRequest)
    case fetchShopEventList(FetchShopInfoRequest)
    case fetchShopReviewList(FetchShopReviewRequest)
}

extension ShopAPI: Router, URLRequestConvertible {
    
    public var baseURL: String {
        return Bundle.main.baseUrl
    }
    
    public var path: String {
        switch self {
        case .fetchShopList: return "/shops"
        case .fetchEventList: return "/shops/events"
        case .fetchShopCategoryList: return "/shops/categories"
        case .fetchShopData(let request): return "/shops/\(request.shopId)"
        case .fetchShopMenuList(let request): return "/shops/\(request.shopId)/menus"
        case .fetchShopEventList(let request): return "/shops/\(request.shopId)/events"
        case .fetchShopReviewList(let request): return "/shops/\(request.shopId)/reviews"
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
        case .fetchShopList, .fetchEventList, .fetchShopCategoryList:
            return nil
        case .fetchShopData(let request), .fetchShopMenuList(let request), .fetchShopEventList(let request):
            return try? request.toDictionary()
        case .fetchShopReviewList(let request):
            return [
                "limit": request.limit,
                "page": request.page,
                "sorter": request.sorter.rawValue
            ]
        }
    }

    public var encoding: ParameterEncoding? {
        switch self {
        case .fetchShopList, .fetchEventList, .fetchShopCategoryList:
            return URLEncoding.default
        case .fetchShopData, .fetchShopMenuList, .fetchShopEventList, .fetchShopReviewList:
            return URLEncoding.queryString
        }
    }
}


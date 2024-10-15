//
//  ShopAPI.swift
//  koin
//
//  Created by 김나훈 on 5/22/24.
//

import Alamofire

enum ShopAPI {
    case fetchShopList(FetchShopListRequest)
    case fetchEventList
    case fetchShopCategoryList
    case fetchShopData(FetchShopDataRequest)
    case fetchShopMenuList(FetchShopDataRequest)
    case fetchShopEventList(FetchShopDataRequest)
    case fetchShopBenefits
    case fetchBeneficialShops(Int)
    
    case fetchReviewList(FetchShopReviewRequest)
    case fetchReview(Int, Int)
    case fetchMyReviewList(FetchMyReviewRequest, Int)
    case postReview(WriteReviewRequest, Int)
    case modifyReview(WriteReviewRequest, Int, Int)
    case deleteReview(Int, Int)
    case reportReview(ReportReviewRequest, Int, Int)
    
    case uploadFiles([Data])
}

extension ShopAPI: Router, URLRequestConvertible {
    
    public var baseURL: String {
        return Bundle.main.baseUrl
    }
    
    public var path: String {
        switch self {
        case .fetchShopBenefits: return "/benefit/categories"
        case .fetchBeneficialShops(let id): return "/benefit/\(id)/shops"
        case .fetchShopList: return "/v2/shops"
        case .fetchEventList: return "/shops/events"
        case .fetchShopCategoryList: return "/shops/categories"
        case .fetchShopData(let request): return "/shops/\(request.shopId)"
        case .fetchShopMenuList(let request): return "/shops/\(request.shopId)/menus"
        case .fetchShopEventList(let request): return "/shops/\(request.shopId)/events"
        case .fetchReviewList(let request): return "/shops/\(request.shopId)/reviews"
        case .fetchReview(let reviewId, let shopId): return "/shops/\(shopId)/reviews/\(reviewId)"
        case .fetchMyReviewList(_, let shopId): return "/shops/\(shopId)/reviews/me"
        case .postReview(_, let shopId): return "/shops/\(shopId)/reviews"
        case .modifyReview(_, let reviewId, let shopId): return "/shops/\(shopId)/reviews/\(reviewId)"
        case .deleteReview(let reviewId, let shopId): return "/shops/\(shopId)/reviews/\(reviewId)"
        case .reportReview(_, let reviewId, let shopId): return "/shops/\(shopId)/reviews/\(reviewId)/reports"
        case .uploadFiles: return "/shops/upload/files"
        }
    }
    
    public var method: Alamofire.HTTPMethod {
        switch self {
        case .postReview, .reportReview, .uploadFiles: .post
        case .modifyReview: .put
        case .deleteReview: .delete
        default: .get
        }
    }
    
    public var headers: [String: String] {
        var baseHeaders: [String: String] = [:]
        switch self {
        case .fetchShopList, .fetchEventList, .fetchShopCategoryList, .fetchShopData, .fetchShopMenuList, .fetchShopEventList, .fetchShopBenefits: break
        default:
            if let token = KeyChainWorker.shared.read(key: .access) {
                baseHeaders["Authorization"] = "Bearer \(token)"
            } 
        }
        switch self {
        case .postReview, .reportReview, .modifyReview, .deleteReview:
            baseHeaders["Content-Type"] = "application/json"
        case .uploadFiles:
            baseHeaders["Content-Type"] = "multipart/form-data"
        default: break
        }
        return baseHeaders
    }
    
    public var parameters: Any? {
        switch self {
        case .fetchEventList, .fetchShopCategoryList, .fetchReview, .deleteReview, .uploadFiles, .fetchShopBenefits, .fetchBeneficialShops:
            return nil
        case .fetchShopData(let request), .fetchShopMenuList(let request), .fetchShopEventList(let request):
            return try? request.toDictionary()
        case .fetchShopList(let request):
            var parameters: [String: Any] = ["sorter": request.sorter.rawValue]
            for filterItem in request.filter {
                           parameters["filter"] = filterItem.rawValue
                       }
               return parameters
        case .fetchReviewList(let request):
            return [
                "limit": request.limit,
                "page": request.page,
                "sorter": request.sorter.rawValue
            ]
        case .fetchMyReviewList(let request, _):
            return try? request.toDictionary()
        case .postReview(let request, _), .modifyReview(let request, _, _):
            return try? JSONEncoder().encode(request)
        case .reportReview(let request, _, _):
            return try? JSONEncoder().encode(request)
        }
    }
    public var encoding: ParameterEncoding? {
        switch self {
        case .fetchEventList, .fetchShopCategoryList, .fetchReviewList, .fetchShopList:
            return URLEncoding.default
        case .fetchShopData, .fetchShopMenuList, .fetchShopEventList:
            return URLEncoding.queryString
        case .postReview, .modifyReview, .reportReview:
            return JSONEncoding.default  
        default:
            return URLEncoding.default
        }
    }
}


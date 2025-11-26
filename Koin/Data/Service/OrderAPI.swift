
import Foundation
import Moya
import Alamofire

enum OrderAPI {
    case fetchOrderShopList(FetchOrderShopListRequest)
}

extension OrderAPI: TargetType {
    var baseURL: URL {
        // TODO: 실제 API Base URL로 변경 필요
        return URL(string: "https://api.stage.koreatech.in")!
    }

    var path: String {
        switch self {
        case .fetchOrderShopList: return "order/shops"
        }
    }

    var method: Moya.Method {
        switch self {
        case .fetchOrderShopList: return .get
        }
    }

    var task: Task {
        switch self {
        case let .fetchOrderShopList(request):
            var parameters: [String: Any] = ["sorter": request.sorter.rawValue]
            
            parameters["filter"] = request.filter.map { $0.rawValue }
            
            if let minAmount = request.minimumOrderAmount {
                parameters["minimum_order_amount"] = minAmount
            }
            
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        }
    }

    var headers: [String : String]? {
        // TODO: 실제 Access Token 주입 로직 필요
        return ["Content-Type": "application/json", "Authorization": "Bearer YOUR_ACCESS_TOKEN"]
    }
}

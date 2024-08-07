//
//  NotiAPI.swift
//  koin
//
//  Created by 김나훈 on 7/27/24.
//

import Alamofire

enum NotiAPI {
    case changeNoti(Alamofire.HTTPMethod, NotiSubscribeRequest)
    case changeNotiDetail(Alamofire.HTTPMethod, NotiSubscribeDetailRequest)
    case fetchNotiList
    case sendDeviceToken
}

extension NotiAPI: Router, URLRequestConvertible {
    
    public var baseURL: String {
        return Bundle.main.baseUrl
    }
    
    public var path: String {
        switch self {
        case .changeNoti: return "/notification/subscribe"
        case .changeNotiDetail: return "/notification/subscribe/detail"
        case .fetchNotiList: return "/notification"
        case .sendDeviceToken: return "/notification"
        }
    }
    
    public var method: Alamofire.HTTPMethod {
        switch self {
        case .changeNoti(let hTTPMethod, _):
            return hTTPMethod
        case .changeNotiDetail(let hTTPMethod, _):
            return hTTPMethod
        case .fetchNotiList:
            return .get
        case .sendDeviceToken:
            return .post
        }
    }
    
    public var headers: [String: String] {
        if let token = KeyChainWorker.shared.read(key: .access) {
            let headers = ["Authorization": "Bearer \(token)",
                           "Content-Type": "application/json" ]
            return headers
        } else {
            return [:]
        }
    }
    
    public var parameters: Any? {
        switch self {
        case .changeNoti(_, let request):
            return try? request.toDictionary()
        case .changeNotiDetail(_, let request):
            return try? request.toDictionary()
        case .fetchNotiList:
            return nil
        case .sendDeviceToken:
            return try? SendDeviceTokenRequest(deviceToken: KeyChainWorker.shared.read(key: .fcm) ?? "").toDictionary()
        }
    }
    
    public var encoding: ParameterEncoding? {
        switch self {
        case .changeNoti, .changeNotiDetail: return URLEncoding.queryString
        case .sendDeviceToken: return JSONEncoding.default
        case .fetchNotiList: return nil
        }
    }
}

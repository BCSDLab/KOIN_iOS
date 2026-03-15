//
//  CallVanAPI.swift
//  koin
//
//  Created by 홍기정 on 3/15/26.
//

import Foundation
import Alamofire

enum CallVanAPI {
    case fetchCallVanList(CallVanListRequestDto)
    case fetchNotification
    case postNotificationRead(Int)
    case postAllNotificationsRead
    case deleteNotification(Int)
    case deleteAllNotifications
    case postData(CallVanPostRequestDto)
}

extension CallVanAPI: Router, URLRequestConvertible {
    
    public var baseURL: String {
        return Bundle.main.baseUrl
    }
    
    public var path: String {
        switch self {
        case .fetchCallVanList: return "/callvan"
        case .fetchNotification: return "/callvan/notifications"
        case .postNotificationRead(let notificationId): return "/callvan/notifications/\(notificationId)/read"
        case .postAllNotificationsRead: return "/callvan/notifications/mark-all-read"
        case .deleteNotification(let notificationId): return "/callvan/notifications/\(notificationId)"
        case .deleteAllNotifications: return "/callvan/notifications"
        case .postData: return "/callvan"
        }
    }
    
    public var method: Alamofire.HTTPMethod {
        switch self {
        case .fetchCallVanList: return .get
        case .fetchNotification: return .get
        case .postNotificationRead: return .post
        case .postAllNotificationsRead: return .post
        case .deleteNotification: return .delete
        case .deleteAllNotifications: return .delete
        case .postData: return .post
        }
    }
    
    public var headers: [String: String] {
        switch self {
        case .fetchCallVanList, .fetchNotification, .postNotificationRead, .postAllNotificationsRead, .deleteNotification, .deleteAllNotifications, .postData:
            return [:]
        }
    }
    
    public var parameters: Any? {
        switch self {
        case .fetchCallVanList(let request):
            return try? request.toDictionary()
        case .postData(let request):
            return try? request.toDictionary()
        case .fetchNotification, .postNotificationRead, .postAllNotificationsRead, .deleteNotification, .deleteAllNotifications:
            return nil
        }
    }
    public var encoding: ParameterEncoding? {
        switch self {
        case .fetchCallVanList:
            return URLEncoding(arrayEncoding: .noBrackets)
        case .postData:
            return JSONEncoding.default
        case .fetchNotification, .postNotificationRead, .postAllNotificationsRead, .deleteNotification, .deleteAllNotifications:
            return nil
        }
    }
    
    
}

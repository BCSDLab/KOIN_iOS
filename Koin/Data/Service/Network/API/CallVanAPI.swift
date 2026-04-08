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
    case participate(Int)
    case quit(Int)
    case close(Int)
    case reopen(Int)
    case complete(Int)
    case fetchCallVanData(Int)
    case report(Int, CallVanReportRequestDto)
    case fetchCallVanChat(Int)
    case postCallVanChat(Int, CallVanChatRequestDto)
    case fetchCallVanSummary(Int)
    case fetchRestriction
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
        case .participate(let postId): return "/callvan/posts/\(postId)/participants"
        case .quit(let postId): return "/callvan/posts/\(postId)/participants"
        case .close(let postId): return "/callvan/posts/\(postId)/close"
        case .reopen(let postId): return "/callvan/posts/\(postId)/reopen"
        case .complete(let postId): return "/callvan/posts/\(postId)/complete"
        case .fetchCallVanData(let postId): return "/callvan/posts/\(postId)"
        case .report(let postId, _): return "/callvan/posts/\(postId)/reports"
        case .fetchCallVanChat(let postId): return "/callvan/posts/\(postId)/chat"
        case .postCallVanChat(let postId, _): return "/callvan/posts/\(postId)/chat"
        case .fetchCallVanSummary(let postId): return "/callvan/posts/\(postId)/summary"
        case .fetchRestriction: return "/callvan/restriction"
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
        case .participate: return .post
        case .quit: return .delete
        case .close: return .put
        case .reopen: return .put
        case .complete: return .put
        case .fetchCallVanData: return .get
        case .report: return .post
        case .fetchCallVanChat: return .get
        case .postCallVanChat: return .post
        case .fetchCallVanSummary: return .get
        case .fetchRestriction: return .get
        }
    }
    
    public var headers: [String: String] {
        var baseHeaders: [String: String] = [:]
        switch self {
        case .report, .postCallVanChat:
            baseHeaders["Content-Type"] = "application/json"
        default:
            break
        }
        return baseHeaders
    }
    
    public var parameters: Any? {
        switch self {
        case .fetchCallVanList(let request):
            return try? request.toDictionary()
        case .postData(let request):
            return try? request.toDictionary()
        case .report(_, let request):
            return try? request.toDictionary()
        case .postCallVanChat(_, let request):
            return try? request.toDictionary()
        default:
            return nil
        }
    }
    public var encoding: ParameterEncoding? {
        switch self {
        case .fetchCallVanList:
            return URLEncoding(arrayEncoding: .noBrackets)
        case .postData, .report, .postCallVanChat, .fetchRestriction:
            return JSONEncoding.default
        default:
            return nil
        }
    }
    
    
}

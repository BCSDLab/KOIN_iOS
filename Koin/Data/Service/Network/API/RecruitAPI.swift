//
//  RecruitAPI.swift
//  koin
//
//  Created by 홍기정 on 10/1/26.
//

import Foundation
import Alamofire

enum RecruitAPI {
    case fetchList(RecruitListRequestDto)
    case fetchData(Int)
    case deleteData(Int)
    case post(RecruitPostRequestDto)
    case modify(Int, RecruitPostRequestDto)
    case fetchMyProfile
    case upsertMyProfile(RecruitProfileRequestDto)
    case apply(Int, RecruitApplyRequestDto)
    case fetchMyApplicationList(RecruitMyApplicationListRequestDto)
    case fetchMyPostList(RecruitMyPostListRequestDto)
    case closeMyPost(Int)
    case fetchMyPostData(Int, RecruitApplicantListRequestDto)
    case fetchApplicant(recruitmentId: Int, applicationId: Int)
    case decideApplicant(recruitmentId: Int, applicationId: Int, RecruitApplicantDecisionRequestDto)
    case fetchChatData(recruitmentId: Int, chatRoomId: Int)
    case fetchDirectChatData(recruitmentId: Int, applicationId: Int)
    case fetchChatMessages(recruitmentId: Int, chatRoomId: Int)
    case postChatMessage(recruitmentId: Int, chatRoomId: Int, RecruitChatPostRequestDto)
    case fetchNotificationList(RecruitNotificationListRequestDto)
    case markAsReadNotification(Int)
    case markAllAsReadNotification
    case deleteNotification(Int)
    case deleteAllNotification
}

extension RecruitAPI: Router, URLRequestConvertible {

    public var baseURL: String {
        return Bundle.main.baseUrl
    }

    public var path: String {
        switch self {
        case .fetchList: return "/team-recruitments"
        case .fetchData(let id): return "/team-recruitments/\(id)"
        case .deleteData(let id): return "/team-recruitments/\(id)"
        case .post: return "/team-recruitments"
        case .modify(let id, _): return "/team-recruitments/\(id)"
        case .fetchMyProfile: return "/team-recruitment-profiles/me"
        case .upsertMyProfile: return "/team-recruitment-profiles/me"
        case .apply(let id, _): return "/team-recruitments/\(id)/applications"
        case .fetchMyApplicationList: return "/team-recruitments/me/applications"
        case .fetchMyPostList: return "/team-recruitments/me/created"
        case .closeMyPost(let id): return "/team-recruitments/\(id)/close"
        case .fetchMyPostData(let id, _): return "/team-recruitments/\(id)/applications"
        case .fetchApplicant(let recruitmentId, let applicationId): return "/team-recruitments/\(recruitmentId)/applications/\(applicationId)"
        case .decideApplicant(let recruitmentId, let applicationId, _): return "/team-recruitments/\(recruitmentId)/applications/\(applicationId)/status"
        case .fetchChatData(let recruitmentId, let chatRoomId): return "/chatroom/team-recruitment/\(recruitmentId)/\(chatRoomId)"
        case .fetchDirectChatData(let recruitmentId, let applicationId): return "/chatroom/team-recruitment/\(recruitmentId)/applications/\(applicationId)/direct"
        case .fetchChatMessages(let recruitmentId, let chatRoomId), .postChatMessage(let recruitmentId, let chatRoomId, _): return "/chatroom/team-recruitment/\(recruitmentId)/\(chatRoomId)/messages"
        case .fetchNotificationList, .deleteAllNotification: return "/team-recruitments/notifications"
        case .markAsReadNotification(let id): return "/team-recruitments/notifications/\(id)/read"
        case .markAllAsReadNotification: return "/team-recruitments/notifications/mark-all-read"
        case .deleteNotification(let id): return "/team-recruitments/notifications/\(id)"
        }
    }

    public var method: Alamofire.HTTPMethod {
        switch self {
        case .fetchList: return .get
        case .fetchData: return .get
        case .deleteData: return .delete
        case .post: return .post
        case .modify: return .put
        case .fetchMyProfile: return .get
        case .upsertMyProfile: return .put
        case .apply: return .post
        case .fetchMyApplicationList: return .get
        case .fetchMyPostList: return .get
        case .closeMyPost: return .put
        case .fetchMyPostData: return .get
        case .fetchApplicant: return .get
        case .decideApplicant: return .put
        case .fetchChatData: return .get
        case .fetchDirectChatData: return .post
        case .fetchChatMessages: return .get
        case .postChatMessage: return .post
        case .fetchNotificationList: return .get
        case .markAsReadNotification, .markAllAsReadNotification: return .post
        case .deleteNotification, .deleteAllNotification: return .delete
        }
    }

    public var headers: [String: String] {
        var baseHeaders: [String: String] = [:]
        switch self {
        case .fetchList, .fetchData, .deleteData, .fetchMyProfile, .fetchMyApplicationList, .fetchMyPostList, .closeMyPost, .fetchMyPostData, .fetchApplicant, .fetchChatData, .fetchDirectChatData, .fetchChatMessages, .fetchNotificationList, .markAsReadNotification, .markAllAsReadNotification, .deleteNotification, .deleteAllNotification:
            break
        case .post, .modify, .upsertMyProfile, .apply, .decideApplicant, .postChatMessage:
            baseHeaders["Content-Type"] = "application/json"
        }
        return baseHeaders
    }

    public var parameters: Any? {
        switch self {
        case .fetchList(let request):
            return try? request.toDictionary()
        case .fetchData, .deleteData, .fetchMyProfile:
            return nil
        case .post(let request), .modify(_, let request):
            return try? request.toDictionary()
        case .upsertMyProfile(let request):
            return try? request.toDictionary()
        case .apply(_, let request):
            return try? request.toDictionary()
        case .fetchMyApplicationList(let request):
            return try? request.toDictionary()
        case .fetchMyPostList(let request):
            return try? request.toDictionary()
        case .fetchMyPostData(_, let request):
            return try? request.toDictionary()
        case .decideApplicant(_, _, let request):
            return try? request.toDictionary()
        case .postChatMessage(_, _, let request):
            return try? request.toDictionary()
        case .fetchNotificationList(let request):
            return try? request.toDictionary()
        case .markAsReadNotification, .markAllAsReadNotification, .deleteNotification, .deleteAllNotification:
            return nil
        case .closeMyPost, .fetchApplicant, .fetchChatData, .fetchDirectChatData, .fetchChatMessages:
            return nil
        }
    }

    public var encoding: ParameterEncoding? {
        switch self {
        case .fetchList, .fetchMyApplicationList, .fetchMyPostList, .fetchMyPostData, .fetchNotificationList:
            return URLEncoding(arrayEncoding: .noBrackets)
        case .markAsReadNotification, .markAllAsReadNotification, .deleteNotification, .deleteAllNotification:
            return nil
        case .closeMyPost, .fetchApplicant, .fetchChatData, .fetchDirectChatData, .fetchChatMessages:
            return nil
        case .fetchData, .deleteData, .fetchMyProfile:
            return nil
        case .post, .modify, .upsertMyProfile, .apply, .decideApplicant, .postChatMessage:
            return JSONEncoding.default
        }
    }
}

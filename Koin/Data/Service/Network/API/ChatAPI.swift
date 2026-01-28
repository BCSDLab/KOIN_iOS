//
//  ChatAPI.swift
//  koin
//
//  Created by 김나훈 on 2/18/25.
//

import Alamofire

enum ChatAPI {
    case fetchChatRoom
    case fetchChatDetail(Int, Int)
    case blockUser(Int, Int)
    case createChatRoom(Int)
    case postChatDetail(Int, Int, PostChatDetailRequest)
}

extension ChatAPI: Router, URLRequestConvertible {
    
    public var baseURL: String {
        return Bundle.main.baseUrl
    }
    
    public var path: String {
        switch self {
        case .fetchChatRoom: return "/chatroom/lost-item"
        case .fetchChatDetail(let articleId, let chatRoomId): return "/chatroom/lost-item/\(articleId)/\(chatRoomId)/messages"
        case .blockUser(let articleId, let chatRoomId): return "/chatroom/lost-item/\(articleId)/\(chatRoomId)/block"
        case .createChatRoom(let articleId): return "/chatroom/lost-item/\(articleId)"
        case .postChatDetail(let articleId, let chatRoomId, _): return "/v2/chatroom/lost-item/\(articleId)/\(chatRoomId)/messages"
        }
    }
    
    public var method: Alamofire.HTTPMethod {
        switch self {
        case .fetchChatRoom, .fetchChatDetail: return .get
        case .blockUser, .createChatRoom, .postChatDetail: return .post
        }
    }
    
    public var headers: [String: String] {
        var baseHeaders: [String: String] = [:]
        switch self {
        case .fetchChatRoom, .fetchChatDetail, .blockUser, .createChatRoom, .postChatDetail:
            if let token = KeychainWorker.shared.read(key: .access) {
                baseHeaders["Authorization"] = "Bearer \(token)"
            }
        }
        switch self {
        case .createChatRoom, .postChatDetail: 
            baseHeaders["Content-Type"] = "application/json"
        default: break
        }
        return baseHeaders
    }
 
    public var parameters: Any? {
        switch self {
        case .fetchChatRoom, .fetchChatDetail, .blockUser, .createChatRoom:
            return nil
        case .postChatDetail(_, _, let request):
            return try? JSONEncoder().encode(request)
        }
    }
    
    public var encoding: ParameterEncoding? {
        switch self {
        case .fetchChatRoom: return URLEncoding.default
        case .postChatDetail: return JSONEncoding.default
        case .fetchChatDetail: return nil
        case .blockUser: return nil
        case .createChatRoom: return nil
        }
    }
}

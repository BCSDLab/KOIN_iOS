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
        }
    }
    
    public var method: Alamofire.HTTPMethod {
        switch self {
        case .fetchChatRoom, .fetchChatDetail: return .get
        case .blockUser, .createChatRoom: return .post
        }
    }
    
    public var headers: [String: String] {
        var baseHeaders: [String: String] = [:]
        switch self {
        case .fetchChatRoom, .fetchChatDetail, .blockUser, .createChatRoom:
            if let token = KeychainWorker.shared.read(key: .access) {
                baseHeaders["Authorization"] = "Bearer \(token)"
            }
        default: break
        }
        switch self {
        case .createChatRoom: baseHeaders["Content-Type"] = "application/json"
        default: break
        }
        return baseHeaders
    }
 
    public var parameters: Any? {
        switch self {
        case .fetchChatRoom, .fetchChatDetail, .blockUser, .createChatRoom: return nil
        }
    }
    
    public var encoding: ParameterEncoding? {
        switch self {
        case .fetchChatRoom: return URLEncoding.default
        case .fetchChatDetail: return nil
        case .blockUser: return nil
        case .createChatRoom: return nil
        }
    }
}

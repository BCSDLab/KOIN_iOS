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
        }
    }
    
    public var method: Alamofire.HTTPMethod {
        switch self {
        case .fetchChatRoom, .fetchChatDetail: return .get
        case .blockUser: return .post
        }
    }
    
    public var headers: [String: String] {
        switch self {
        case .fetchChatRoom, .fetchChatDetail, .blockUser:
            if let token = KeychainWorker.shared.read(key: .access) {
                let headers = ["Authorization": "Bearer \(token)"]
                return headers
            } else {
                return [:]
            }
        }
    }
    
    public var parameters: Any? {
        switch self {
        case .fetchChatRoom, .fetchChatDetail: return nil
        case .blockUser: return nil
        }
    }
    
    public var encoding: ParameterEncoding? {
        switch self {
        case .fetchChatRoom: return URLEncoding.default
        case .fetchChatDetail: return nil
        case .blockUser: return nil
        }
    }
}

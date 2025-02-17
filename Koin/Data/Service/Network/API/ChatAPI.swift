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
}

extension ChatAPI: Router, URLRequestConvertible {
    
    public var baseURL: String {
        return Bundle.main.baseUrl
    }
    
    public var path: String {
        switch self {
        case .fetchChatRoom: return "/chatroom/lost-item"
        case .fetchChatDetail(let articleId, let chatRoomId): return "/chatroom/lost-item/\(articleId)/\(chatRoomId)/messages"
        }
    }
    
    public var method: Alamofire.HTTPMethod {
        switch self {
        case .fetchChatRoom, .fetchChatDetail: return .get
        }
    }
    
    public var headers: [String: String] {
        switch self {
        case .fetchChatRoom, .fetchChatDetail:
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
        case .fetchChatRoom: return nil
        case .fetchChatDetail: return nil
        }
    }
    
    public var encoding: ParameterEncoding? {
        switch self {
        case .fetchChatRoom: return URLEncoding.default
        case .fetchChatDetail: return nil
        }
    }
}

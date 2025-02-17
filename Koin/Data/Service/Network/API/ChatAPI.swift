//
//  ChatAPI.swift
//  koin
//
//  Created by 김나훈 on 2/18/25.
//

import Alamofire

enum ChatAPI {
    case fetchChatRoom
}

extension ChatAPI: Router, URLRequestConvertible {
    
    public var baseURL: String {
        return Bundle.main.baseUrl
    }
    
    public var path: String {
        switch self {
        case .fetchChatRoom: return "/chatroom/lost-item"
        }
    }
    
    public var method: Alamofire.HTTPMethod {
        switch self {
        case .fetchChatRoom: return .get
        }
    }
    
    public var headers: [String: String] {
        switch self {
        case .fetchChatRoom:
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
        }
    }
    
    public var encoding: ParameterEncoding? {
        switch self {
        case .fetchChatRoom: return URLEncoding.default
        }
    }
}

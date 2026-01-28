//
//  PostChatDetailRequest.swift
//  koin
//
//  Created by 홍기정 on 1/28/26.
//

import Foundation

struct PostChatDetailRequest: Encodable {
    
    let userNickname: String
    let content: String
    let isImage: Bool
    
    enum CodingKeys: String, CodingKey {
        case userNickname = "user_nickname"
        case content
        case isImage = "is_image"
    }
}

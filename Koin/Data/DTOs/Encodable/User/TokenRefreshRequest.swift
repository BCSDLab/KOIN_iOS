//
//  AccessTokenRequest.swift
//  koin
//
//  Created by 김나훈 on 3/20/24.
//

import Foundation

struct TokenRefreshRequest: Encodable {
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
    }
    
}

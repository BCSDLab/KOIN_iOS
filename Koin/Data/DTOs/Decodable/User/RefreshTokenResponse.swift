//
//  RefreshTokenResponse.swift
//  koin
//
//  Created by 김나훈 on 3/20/24.
//

import Foundation

struct RefreshTokenResponse: Decodable {
    let refreshToken: String
    let token: String
    
    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
        case token
    }
}

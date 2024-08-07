//
//  RefreshTokenRequest.swift
//  koin
//
//  Created by 김나훈 on 7/24/24.
//


struct RefreshTokenRequest: Encodable {
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
    }
}

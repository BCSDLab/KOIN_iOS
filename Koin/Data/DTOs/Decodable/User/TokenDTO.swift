//
//  TokenDTO.swift
//  koin
//
//  Created by 김나훈 on 3/17/24.
//

import Foundation

struct TokenDTO: Decodable {
    let refreshToken: String
    let token: String
    
    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
        case token
    }
}

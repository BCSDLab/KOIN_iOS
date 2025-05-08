//
//  LoginRequest.swift
//  koin
//
//  Created by 김나훈 on 3/17/24.
//

import Foundation

struct LoginRequest: Encodable {
    let loginId, loginPw: String

    enum CodingKeys: String, CodingKey {
        case loginId = "login_id"
        case loginPw = "login_pw"
    }
}

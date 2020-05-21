//
//  TokenCheckResponse.swift
//  Koin
//
//  Created by 정태훈 on 2020/05/12.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation

struct TokenCheckResponse: Codable {
    let id: Int
    let portal_account: String
    let password: String
    let nickname: String
    let anonymous_nickname: String
    let name: String
    let student_number: String
    let major: String
    let identity: Int
    let is_graduated: Bool
    let phone_number: String
    let gender: Int
    let is_authed: Bool
    let auth_token: String
    let auth_expired_at: Int
    let reset_token: String?
    let reset_expired_at: Int?
    let last_logged_at: Int?
    let remember_token: String?
    let profile_image_url: String?
    let authority: String?
    let authorities: String?
    let accountNonExpired: Bool
    let accountNonLocked: Bool
    let credentialNonExpired: Bool
    let enabled: Bool
    let username: String
}

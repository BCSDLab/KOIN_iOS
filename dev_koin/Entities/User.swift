//
//  User.swift
//  dev_koin
//
//  Created by 정태훈 on 2019/12/22.
//  Copyright © 2019 정태훈. All rights reserved.
//

import Foundation

struct User: Codable {
    let accountNonExpired: Bool
    let accountNonLocked: Bool
    let anonymousNickname: String
    let credentialsNonExpired: Bool
    let enabled: Bool
    let gender: Int
    let identity: Int
    let isGraduated: Bool
    let major: String
    let name: String
    let nickname: String
    let phoneNumber: String
    let portalAccount: String
    let studentNumber: String
    let username: String
    private enum CodingKeys: String, CodingKey {
        case accountNonExpired = "accountNonExpired"
        case accountNonLocked = "accountNonLocked"
        case anonymousNickname = "anonymous_nickname"
        case credentialsNonExpired = "credentialsNonExpired"
        case enabled = "enabled"
        case gender = "gender"
        case identity = "identity"
        case isGraduated = "is_graduated"
        case major = "major"
        case name = "name"
        case nickname = "nickname"
        case phoneNumber = "phone_number"
        case portalAccount = "portal_account"
        case studentNumber = "student_number"
        case username = "username"
    }
}

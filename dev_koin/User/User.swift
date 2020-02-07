//
//  User.swift
//  dev_koin
//
//  Created by 정태훈 on 2019/12/22.
//  Copyright © 2019 정태훈. All rights reserved.
//

import Foundation

struct User: Codable {
    var id: Int
    var accountNonExpired: Bool
    var accountNonLocked: Bool
    var anonymousNickname: String
    var credentialsNonExpired: Bool
    var enabled: Bool
    var gender: Int?
    var identity: Int?
    var isGraduated: Bool?
    var major: String?
    var name: String?
    var nickname: String?
    var phoneNumber: String?
    var portalAccount: String
    var studentNumber: String?
    var username: String?
    private enum CodingKeys: String, CodingKey {
        case id = "id"
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

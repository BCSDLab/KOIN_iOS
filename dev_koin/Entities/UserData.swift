//
//  User.swift
//  dev_koin
//
//  Created by 정태훈 on 2019/12/10.
//  Copyright © 2019 정태훈. All rights reserved.
//

struct UserData: Codable {
    struct User: Codable {
        var accountNonExpired: Bool
        var accountNonLocked: Bool
        var anonymous_nickname: String
        var credentialsNonExpired: Bool
        var enabled: Bool
        var gender: Int
        var id: Int
        var identity: Int
        var is_graduated: Bool
        var major: String
        var name: String
        var nickname: String
        var phone_number: String
        var portal_account: String
        var student_number: String
        var username: String
    }
    var token: String
    var ttl: Int
    var user: User
}

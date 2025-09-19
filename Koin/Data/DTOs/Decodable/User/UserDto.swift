//
//  UserDto.swift
//  koin
//
//  Created by 김나훈 on 3/20/24.
//


import Foundation

struct UserDto: Decodable, Equatable {
    let id: Int?
    let loginId: String?
    let anonymousNickname: String?
    var email: String?
    var gender: Int?
    var major: String?
    var name: String?
    var nickname: String?
    var studentNumber: String?
    var phoneNumber: String?
    var userType: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case loginId = "login_id"
        case anonymousNickname = "anonymous_nickname"
        case email, gender, major, name, nickname
        case phoneNumber = "phone_number"
        case studentNumber = "student_number"
        case userType = "user_type"
    }
}

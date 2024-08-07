//
//  UserDTO.swift
//  koin
//
//  Created by 김나훈 on 3/20/24.
//


import Foundation

struct UserDTO: Decodable {
    let anonymousNickname: String?
    let email: String?
    let gender: Int?
    let major: String?
    let name: String?
    let nickname: String?
    let studentNumber: String?
    let phoneNumber: String?
    
    enum CodingKeys: String, CodingKey {
        case anonymousNickname = "anonymous_nickname"
        case email, gender, major, name, nickname
        case phoneNumber = "phone_number"
        case studentNumber = "student_number"
    }
}

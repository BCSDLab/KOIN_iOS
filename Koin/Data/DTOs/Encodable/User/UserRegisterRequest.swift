//
//  UserRegisterRequest.swift
//  koin
//
//  Created by 김나훈 on 3/26/24.
//

import Foundation

struct UserRegisterRequest: Encodable {
    let email: String
    let gender: Int?
    let isGraduated: Bool?
    let major: String?
    let name: String?
    let nickname: String?
    var password: String
    let phoneNumber: String?
    let studentNumber: String?
    
    enum CodingKeys: String, CodingKey {
        case email
        case gender
        case isGraduated = "is_graduated"
        case major
        case name
        case nickname
        case password
        case phoneNumber = "phone_number"
        case studentNumber = "student_number"
    }
    
    mutating func sha256() {
        password = EncodingWorker().sha256(text: password)
    }
}

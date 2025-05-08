//
//  StudentRegisterFormRequest.swift
//  koin
//
//  Created by 이은지 on 5/6/25.
//

import Foundation

struct StudentRegisterFormRequest: Encodable {
    let name, phoneNumber, loginId: String
    var password: String
    let department, studentNumber, gender: String
    let email, nickname: String?

    enum CodingKeys: String, CodingKey {
        case name
        case phoneNumber = "phone_number"
        case loginId = "login_id"
        case password, department
        case studentNumber = "student_number"
        case gender, email, nickname
    }
    
    mutating func sha256() {
        password = EncodingWorker().sha256(text: password)
    }
}

//
//  UserPutRequest.swift
//  koin
//
//  Created by 김나훈 on 3/21/24.
//

struct UserPutRequest: Encodable {
    let gender: Int?
    let identity: Int?
    let isGraduated: Bool?
    let major: String?
    let name: String?
    let nickname: String?
    var password: String?
    let phoneNumber: String?
    let studentNumber: String?
    
    enum CodingKeys: String, CodingKey {
        case gender, identity, major, name, nickname, password
        case isGraduated = "is_graduated"
        case phoneNumber = "phone_number"
        case studentNumber = "student_number"
    }
    
    mutating func sha256() {
        if let nonHashedPassword = password {
            password = EncodingWorker().sha256(text: nonHashedPassword)
        } else {
            password = nil
        }
    }
}

//
//  GeneralRegisterFormRequest.swift
//  koin
//
//  Created by 이은지 on 5/6/25.
//

import Foundation

struct GeneralRegisterFormRequest: Encodable {
    let name, phoneNumber, loginId, gender: String
    var password: String
    let email, nickname: String?

    enum CodingKeys: String, CodingKey {
        case name
        case phoneNumber = "phone_number"
        case loginId = "login_id"
        case password, gender, email, nickname
    }
    
    mutating func sha256() {
        password = EncodingWorker().sha256(text: password)
    }
}

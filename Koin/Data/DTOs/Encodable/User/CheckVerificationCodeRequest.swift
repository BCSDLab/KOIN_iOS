//
//  CheckVerificationCodeRequest.swift
//  koin
//
//  Created by 이은지 on 4/28/25.
//

struct CheckVerificationCodeRequest: Encodable {
    let phoneNumber, verificationCode: String

    enum CodingKeys: String, CodingKey {
        case phoneNumber = "phone_number"
        case verificationCode = "verification_code"
    }
}

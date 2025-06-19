//
//  CheckVerificationEmailRequest.swift
//  koin
//
//  Created by 김나훈 on 6/18/25.
//

struct CheckVerificationEmailRequest: Codable {
    let email, verificationCode: String

    enum CodingKeys: String, CodingKey {
        case email
        case verificationCode = "verification_code"
    }
}

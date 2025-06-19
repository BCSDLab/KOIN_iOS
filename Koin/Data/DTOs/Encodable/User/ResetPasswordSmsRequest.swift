//
//  ResetPasswordSmsRequest.swift
//  koin
//
//  Created by 김나훈 on 6/19/25.
//

struct ResetPasswordSmsRequest: Codable {
    let loginId, phoneNumber, newPassword: String

    enum CodingKeys: String, CodingKey {
        case loginId = "login_id"
        case phoneNumber = "phone_number"
        case newPassword = "new_password"
    }
}

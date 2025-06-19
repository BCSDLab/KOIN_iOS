//
//  ResetPasswordEmailRequest.swift
//  koin
//
//  Created by 김나훈 on 6/19/25.
//

struct ResetPasswordEmailRequest: Codable {
    let loginId, email, newPassword: String

    enum CodingKeys: String, CodingKey {
        case loginId = "login_id"
        case email 
        case newPassword = "new_password"
    }
}

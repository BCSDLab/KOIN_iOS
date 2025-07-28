//
//  ChangePasswordRequest.swift
//  koin
//
//  Created by 김나훈 on 7/14/25.
//

struct ChangePasswordRequest: Codable {
    let newPassword: String

    enum CodingKeys: String, CodingKey {
        case newPassword = "new_password"
    }
}

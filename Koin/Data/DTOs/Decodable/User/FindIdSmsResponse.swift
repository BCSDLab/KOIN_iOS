//
//  FindIdSmsResponse.swift
//  koin
//
//  Created by 김나훈 on 6/18/25.
//

import Foundation

struct FindIdSmsResponse: Codable {
    let loginID: String

    enum CodingKeys: String, CodingKey {
        case loginID = "login_id"
    }
}

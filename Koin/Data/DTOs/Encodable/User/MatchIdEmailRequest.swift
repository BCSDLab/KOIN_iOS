//
//  MatchIdEmailRequest.swift
//  koin
//

import Foundation

struct MatchIdEmailRequest: Codable {
    let loginId, email: String

    enum CodingKeys: String, CodingKey {
        case loginId = "login_id"
        case email
    }
}

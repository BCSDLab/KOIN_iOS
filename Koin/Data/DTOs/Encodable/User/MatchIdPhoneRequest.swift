//
//  MatchIdPhoneRequest.swift
//  koin
//

import Foundation

struct MatchIdPhoneRequest: Codable {
    let loginId, phoneNumber: String

    enum CodingKeys: String, CodingKey {
        case loginId = "login_id"
        case phoneNumber = "phone_number"
    }
}

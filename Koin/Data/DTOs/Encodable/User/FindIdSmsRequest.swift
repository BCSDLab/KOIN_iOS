//
//  FindIdSmsRequest.swift
//  koin
//
//  Created by 김나훈 on 6/18/25.
//

import Foundation

struct FindIdSmsRequest: Codable {
    let phoneNumber: String

    enum CodingKeys: String, CodingKey {
        case phoneNumber = "phone_number"
    }
}

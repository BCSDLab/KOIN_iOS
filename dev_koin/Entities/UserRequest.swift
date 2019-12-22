//
//  UserRequest.swift
//  dev_koin
//
//  Created by 정태훈 on 2019/12/22.
//  Copyright © 2019 정태훈. All rights reserved.
//

import Foundation

struct UserRequest: Codable {
    let token: String?
    let ttl: Int?
    let user: User?
    private enum CodingKeys: String, CodingKey {
        case token = "token"
        case ttl = "ttl"
        case user = "user"
    }
}

//
//  LogInDTO.swift
//  koin
//
//  Created by 김나훈 on 3/17/24.
//

import Foundation

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

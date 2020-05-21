//
//  UserResponseData.swift
//  Koin
//
//  Created by 정태훈 on 2020/05/17.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation

struct DeleteUserResponseData: Codable {
    let success: Bool
}

struct AddUserResponseData: Codable {
    let success: String
}

struct ErrorResponse: Codable {
    let error: ErrorData
}

struct ErrorData: Codable {
    let code: Int
    let message: String
}

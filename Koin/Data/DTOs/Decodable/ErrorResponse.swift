//
//  ErrorResponse.swift
//  koin
//
//  Created by 김나훈 on 3/18/24.
//

import Foundation

struct ErrorResponse: Decodable, Error {
    let code: String
    let message: String
}

//
//  ErrorResponseDto.swift
//  koin
//
//  Created by 김나훈 on 3/18/24.
//

import Foundation

struct ErrorResponseDto: Decodable {
    let code: String
    let message: String
}

extension ErrorResponseDto {
    func toDomain(withStatusCode statusCode: Int) -> ErrorResponse {
        return ErrorResponse(statusCode: statusCode, code: self.code, message: self.message)
    }
}

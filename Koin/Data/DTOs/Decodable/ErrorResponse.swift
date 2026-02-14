//
//  ErrorResponse.swift
//  koin
//
//  Created by 김나훈 on 3/18/24.
//

import Foundation

struct ErrorResponse: Decodable, Error {
    var statusCode: Int?
    let code: String
    let message: String
    
    func statusCode(_ statusCode: Int) -> ErrorResponse{
        ErrorResponse(statusCode: statusCode, code: self.code, message: self.message)
    }
}

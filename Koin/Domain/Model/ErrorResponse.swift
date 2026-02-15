//
//  ErrorResponse.swift
//  koin
//
//  Created by 홍기정 on 2/15/26.
//

import Foundation

struct ErrorResponse: Error {
    var statusCode: Int? = nil
    let code: String
    let message: String
    
    init(statusCode: Int? = nil, code: String, message: String) {
        self.statusCode = statusCode
        self.code = code
        self.message = message
    }
    
    init(_ userInputError: UserInputError) {
        self.code = ""
        self.message = userInputError.errorDescription ?? ""
    }
}

extension ErrorResponse {
    
    static func decodingError(_ statusCode: Int) -> Self {
        return ErrorResponse(statusCode: statusCode, code: "DECODING_ERROR", message: "디코딩 실패")
    }
    static func emptyDataError(_ statusCode: Int) -> Self {
        return ErrorResponse(statusCode: statusCode, code: "EMPTY_DATA_ERROR", message: "응답 데이터가 없습니다")
    }
    
    static let unexpectedInternalError = ErrorResponse(statusCode: nil, code: "UNEXPECTED_INTERNAL_ERROR", message: "내부 오류")
    static let typeCastingError = ErrorResponse(statusCode: nil, code: "TYPE_CASTING_ERROR", message: "타입 캐스팅 실패")
    static let networkError = ErrorResponse(statusCode: nil, code: "NETWORK_ERROR", message: "서버 응답 오류")
    static let invalidUrl = ErrorResponse(statusCode: nil, code: "INVALID_URL", message: "URL이 유효하지 않습니다.")
    static let invalidApi = ErrorResponse(statusCode: nil, code: "INVALID_API", message: "API가 유효하지 않습니다.")
    static let fileManagerFailedDirectory = ErrorResponse(statusCode: nil, code: "FILEMANAGER_FAILED_DIRECTORY", message: "파일 저장 위치 찾기 실패")
    static let deleteKeywordError = ErrorResponse(statusCode: nil, code: "DELETE_KEYWORD_ERROR", message: "로그인에 실패하여 코어데이터에서 키워드 삭제")
    static let createKeywordError = ErrorResponse(statusCode: nil, code: "CREATE_KEYWORD_ERROR", message: "로그인에 실패하여 코어데이터에서 키워드 삭제")
}

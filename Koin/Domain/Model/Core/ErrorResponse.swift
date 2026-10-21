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
        return ErrorResponse(statusCode: statusCode, code: "DECODING_ERROR", message: "오류가 발생했습니다.")
    }
    static func emptyDataError(_ statusCode: Int) -> Self {
        return ErrorResponse(statusCode: statusCode, code: "EMPTY_DATA_ERROR", message: "오류가 발생했습니다.")
    }
}
extension ErrorResponse {
    static let unexpectedInternalError = ErrorResponse(
        code: "UNEXPECTED_INTERNAL_ERROR",
        message: "오류가 발생했습니다."
    )
    static let typeCastingError = ErrorResponse(
        code: "TYPE_CASTING_ERROR",
        message: "오류가 발생했습니다."
    )
    static let networkError = ErrorResponse(
        code: "NETWORK_ERROR",
        message: "오류가 발생했습니다."
    )
    static let invalidUrl = ErrorResponse(
        code: "INVALID_URL",
        message: "URL이 유효하지 않습니다."
    )
    static let recruitRelatedUrlSchemeError = ErrorResponse(
        code: "RECRUIT_RELATED_URL_SCHEME_ERROR",
        message: "URL은 https:// 로 시작해야 합니다."
    )
    static let deletedRecruitment = ErrorResponse(
        code: "DELETED_RECRUITMENT",
        message: "삭제된 모집글입니다."
    )
    static let invalidApi = ErrorResponse(
        code: "INVALID_API",
        message: "오류가 발생했습니다."
    )
    static let fileManagerFailedDirectory = ErrorResponse(
        code: "FILEMANAGER_FAILED_DIRECTORY",
        message: "오류가 발생했습니다."
    )
    static let deleteKeywordError = ErrorResponse(
        code: "DELETE_KEYWORD_ERROR",
        message: "오류가 발생했습니다."
    )
    static let createKeywordError = ErrorResponse(
        code: "CREATE_KEYWORD_ERROR",
        message: "오류가 발생했습니다."
    )
    static let dateFormatterFailedConvert = ErrorResponse(
        code: "DATEFORMATTER_FAILED_CONVERT",
        message: "오류가 발생했습니다."
    )
    static let imageUploadError = ErrorResponse(
        code: "IMAGE_UPLOAD_ERROR",
        message: "오류가 발생했습니다."
    )
    static let unknownUserAssignType = ErrorResponse(
        code: "UNKNOWN_USER_ASSIGN_TYPE",
        message: "오류가 발생했습니다."
    )
    
    static let cameraUnavailable = ErrorResponse(
        code: "CAMERA_UNAVAILABLE",
        message: "카메라를 사용할 수 없습니다."
    )
}

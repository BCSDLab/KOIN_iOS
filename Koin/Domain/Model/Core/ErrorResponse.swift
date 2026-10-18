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
}
extension ErrorResponse {
    static let unexpectedInternalError = ErrorResponse(
        code: "UNEXPECTED_INTERNAL_ERROR",
        message: "내부 오류"
    )
    static let typeCastingError = ErrorResponse(
        code: "TYPE_CASTING_ERROR",
        message: "타입 캐스팅 실패"
    )
    static let networkError = ErrorResponse(
        code: "NETWORK_ERROR",
        message: "서버 응답 오류"
    )
    static let invalidUrl = ErrorResponse(
        code: "INVALID_URL",
        message: "URL이 유효하지 않습니다."
    )
    static let recruitRelatedUrlSchemeError = ErrorResponse(
        code: "RECRUIT_RELATED_URL_SCHEME_ERROR",
        message: "링크는 https:// 로 시작해야 합니다."
    )
    static let deletedRecruitment = ErrorResponse(
        code: "DELETED_RECRUITMENT",
        message: "삭제된 모집글입니다."
    )
    static let invalidApi = ErrorResponse(
        code: "INVALID_API",
        message: "API가 유효하지 않습니다."
    )
    static let fileManagerFailedDirectory = ErrorResponse(
        code: "FILEMANAGER_FAILED_DIRECTORY",
        message: "파일 저장 위치 찾기 실패"
    )
    static let deleteKeywordError = ErrorResponse(
        code: "DELETE_KEYWORD_ERROR",
        message: "로그인에 실패하여 코어데이터에서 키워드 삭제"
    )
    static let createKeywordError = ErrorResponse(
        code: "CREATE_KEYWORD_ERROR",
        message: "로그인에 실패하여 코어데이터에서 키워드 저장"
    )
    static let dateFormatterFailedConvert = ErrorResponse(
        code: "DATEFORMATTER_FAILED_CONVERT",
        message: "날짜 변환 실패"
    )
    static let imageUploadError = ErrorResponse(
        code: "IMAGE_UPLOAD_ERROR",
        message: "이미지 전송 실패"
    )
    static let unknownUserAssignType = ErrorResponse(
        code: "UNKNOWN_USER_ASSIGN_TYPE",
        message: "알 수 없는 실험군입니다."
    )
}

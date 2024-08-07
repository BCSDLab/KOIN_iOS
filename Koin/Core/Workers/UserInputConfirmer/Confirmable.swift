//
//  UserDataConfirmer.swift
//  koin
//
//  Created by 김나훈 on 3/26/24.
//

import Foundation

// 비밀번호를 검증하기 위함.
// 만약 id 검증 등 다른 곳에서도 추가로 사용할 수 있기 때문에 1번 추상화 했음.
protocol Confirmable {
    
    func confirm(text: String) -> Result<Void, UserInputError>
}

enum UserInputError: String, Error {
    
    case passwordMatchShouldAccord
    case invalidPasswordLength
    case invalidPasswordInput
}

extension UserInputError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .passwordMatchShouldAccord:
            return "비밀번호 확인이 일치하지 않습니다."
        case .invalidPasswordLength:
            return "비밀번호 길이가 제약조건을 벗어납니다."
        case .invalidPasswordInput:
            return "비밀번호는 특수문자, 숫자를 포함해야합니다."
        }
    }
}

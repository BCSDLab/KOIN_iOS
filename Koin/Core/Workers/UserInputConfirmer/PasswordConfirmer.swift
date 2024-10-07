//
//  PasswordConfirmer.swift
//  koin
//
//  Created by 김나훈 on 3/26/24.
//

import Foundation
// 비밀번호 검증 실제 로직
struct PasswordConfirmer: Confirmable {
    
    private let passwordMatchText: String
    init(passwordMatchText: String) {
        self.passwordMatchText = passwordMatchText
    }
    
    func confirm(text: String) -> Result<Void, UserInputError> {
        if checkPasswordInput(password: text) { return .failure(.invalidPasswordInput) }
        else if checkPasswordLength(password: text) { return .failure(.invalidPasswordLength) }
        else if checkPasswordMatch(password: text) { return .failure(.passwordMatchShouldAccord) }
        
        return .success(())
    }
  
    private func checkPasswordMatch(password: String) -> Bool{
        return passwordMatchText != password
    }
    
    private func checkPasswordLength(password: String) -> Bool {
        return !(6...18).contains(password.count)
    }
    
    private func checkPasswordInput(password: String) -> Bool {
        // 특수문자 패턴을 ASCII 값 기반으로 처리 (특수문자: ASCII 32~126 중 숫자, 대소문자 제외)
        let containsSpecialCharacter = password.contains { character in
            let asciiValue = character.asciiValue ?? 0
            return (asciiValue >= 32 && asciiValue <= 126) &&
                   !(asciiValue >= 48 && asciiValue <= 57) &&  // 숫자 제외
                   !(asciiValue >= 65 && asciiValue <= 90) &&  // 대문자 제외
                   !(asciiValue >= 97 && asciiValue <= 122)    // 소문자 제외
        }

        // 숫자 포함 여부 확인 (ASCII 코드: 48~57)
        let containsDigit = password.contains { character in
            let asciiValue = character.asciiValue ?? 0
            return (asciiValue >= 48 && asciiValue <= 57)
        }
        
        // 특수문자 또는 숫자가 없는 경우 true를 반환 (즉, 조건을 만족하지 않으면 true)
        return !containsSpecialCharacter || !containsDigit
    }
}

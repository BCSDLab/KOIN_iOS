//
//  PasswordValidator.swift
//  koin
//
//  Created by 김나훈 on 9/6/24.
//

import Foundation

struct PasswordValidator {
    
    func validate(password: String) -> (Bool, Bool, Bool, Bool) {
        
        let containsEnglish = password.range(of: "[a-zA-Z]", options: .regularExpression) != nil
        
        let containsNumber = password.range(of: "[0-9]", options: .regularExpression) != nil
        
        let containsSpecialCharacter = password.contains { character in
            let asciiValue = character.asciiValue ?? 0
            return (asciiValue >= 32 && asciiValue <= 126) &&
            !(asciiValue >= 48 && asciiValue <= 57) && // 숫자 제외
            !(asciiValue >= 65 && asciiValue <= 90) && // 대문자 제외
            !(asciiValue >= 97 && asciiValue <= 122)   // 소문자 제외
        }
        let isValidLength = password.count >= 6 && password.count <= 18
        
        return (!containsEnglish, !containsNumber, !containsSpecialCharacter, !isValidLength)
    }
}

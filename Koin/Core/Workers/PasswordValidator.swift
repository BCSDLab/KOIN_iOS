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
    
        let containsSpecialCharacter = password.range(of: "[!@#$%^&*(),.?\":{}|<>]", options: .regularExpression) != nil
        
        let isValidLength = password.count >= 6 && password.count <= 18
        
        return (!containsEnglish, !containsNumber, !containsSpecialCharacter, !isValidLength)
    }
}

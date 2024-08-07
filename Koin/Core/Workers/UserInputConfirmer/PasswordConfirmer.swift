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
        let specialCharacterPattern = ".*[!@#$%^&*]+.*"
        let digitPattern = ".*[0-9]+.*"
               
        let specialCharacterResult = password.range(of: specialCharacterPattern, options: .regularExpression) == nil
        let digitResult = password.range(of: digitPattern, options: .regularExpression) == nil
            
        return specialCharacterResult || digitResult
    }
   
}

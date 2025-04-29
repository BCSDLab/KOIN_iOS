//
//  UITextField+.swift
//  koin
//
//  Created by 이은지 on 4/29/25.
//

import UIKit

extension UITextField {
    // 아이디 정규식
    func isValidIDFormat() -> Bool {
        guard let text = self.text else { return false }
        let regex = "^[a-z0-9_.-]{1,13}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: text)
    }
    
    // 비밀번호 정규식
    func isValidPasswordFormat() -> Bool {
        guard let text = self.text else { return false }
        let regex = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[!@#$%^&*])[A-Za-z\\d!@#$%^&*]{6,18}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: text)
    }
}

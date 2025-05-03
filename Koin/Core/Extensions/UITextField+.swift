//
//  UITextField+.swift
//  koin
//
//  Created by 이은지 on 4/29/25.
//

import UIKit

extension UITextField {
    // 기본 텍스트 필드 설정
    func configureDefaultTextField() {
        self.autocorrectionType = .no
        self.spellCheckingType = .no
        self.autocapitalizationType = .none
        self.clearsOnBeginEditing = false
    }
    
    // 텍스트 필드에 placeholder 설정
    func setCustomPlaceholder(text: String, textColor: UIColor, font: UIFont) {
        self.clearButtonMode = .never
        self.attributedPlaceholder = NSAttributedString(string: text, attributes: [
            .foregroundColor: textColor,
            .font: font
        ])
    }
    
    // 텍스트 필드 오른쪽 버튼 추가
    func setRightButton(image: UIImage?, target: Any?, action: Selector) {
        let rightButton = UIButton(type: .custom)
        rightButton.setImage(image, for: .normal)
        rightButton.addTarget(target, action: action, for: .touchUpInside)
        self.rightView = rightButton
        self.rightViewMode = .whileEditing
    }
    
    // 아이디 정규식
    func isValidIdFormat() -> Bool {
        guard let text = self.text else { return false }
        let regex = "^[a-z0-9_.-]{5,13}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: text)
    }
    
    // 비밀번호 정규식
    func isValidPasswordFormat() -> Bool {
        guard let text = self.text else { return false }
        let regex = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[!@#$%^&*])[A-Za-z\\d!@#$%^&*]{6,18}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: text)
    }
}

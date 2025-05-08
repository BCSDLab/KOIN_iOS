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
    
    // 텍스트 필드 토글 버튼
    func setRightToggleButton(image: UIImage?, target: Any?, action: Selector) {
        let button = UIButton(type: .custom)
        button.setImage(image, for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        button.tintColor = .appColor(.neutral800)
        button.addTarget(target, action: action, for: .touchUpInside)
        
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 32, height: 20))
        container.addSubview(button)
        button.center = container.center
        
        self.rightView = container
        self.rightViewMode = .always
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
    
    // 텍스트 필드 underline
    func setUnderline(color: UIColor, thickness: CGFloat = 1.0, leftPadding: CGFloat = 0, rightPadding: CGFloat = 0) {

        self.layer.sublayers?
            .filter { $0.name == "underlineLayer" }
            .forEach { $0.removeFromSuperlayer() }
        
        let underline = CALayer()
        underline.name = "underlineLayer"
        underline.backgroundColor = color.cgColor
        underline.frame = CGRect(
            x: leftPadding,
            y: self.bounds.height - thickness,
            width: self.bounds.width - leftPadding - rightPadding,
            height: thickness
        )
        
        self.layer.addSublayer(underline)
        self.layer.masksToBounds = true
    }
}

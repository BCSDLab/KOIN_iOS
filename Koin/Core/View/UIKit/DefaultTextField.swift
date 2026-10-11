//
//  DefaultTextField.swift
//  koin
//
//  Created by 이은지 on 6/5/25.
//

import UIKit

final class DefaultTextField: UITextField {
    
    init(placeholder: String, placeholderColor: UIColor, font: UIFont) {
        super.init(frame: .zero)
        configureDefaultTextField()
        setCustomPlaceholder(text: placeholder, textColor: placeholderColor, font: font)
        self.font = font
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureDefaultTextField() {
        self.autocorrectionType = .no
        self.spellCheckingType = .no
        self.autocapitalizationType = .none
        self.clearsOnBeginEditing = false
        self.clearButtonMode = .never
    }

    private func setCustomPlaceholder(text: String, textColor: UIColor, font: UIFont) {
        self.attributedPlaceholder = NSAttributedString(string: text, attributes: [
            .foregroundColor: textColor,
            .font: font
        ])
    }
}

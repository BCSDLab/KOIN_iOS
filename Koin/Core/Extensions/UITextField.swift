//
//  UITextField.swift
//  koin
//
//  Created by 이은지 on 4/29/25.
//

import UIKit

extension UITextField {
    func isValidIDFormat() -> Bool {
        guard let text = self.text else { return false }
        let regex = "^[a-z0-9_.-]{1,13}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: text)
    }
}

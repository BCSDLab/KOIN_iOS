//
//  UIButton+.swift
//  koin
//
//  Created by 이은지 on 4/29/25.
//

import UIKit

extension UIButton {
    func updateState(isEnabled: Bool, enabledColor: UIColor, disabledColor: UIColor) {
        self.isEnabled = isEnabled
        self.backgroundColor = isEnabled ? enabledColor : disabledColor
        self.setTitleColor(isEnabled ? .white : .appColor(.neutral600), for: .normal)
    }
}

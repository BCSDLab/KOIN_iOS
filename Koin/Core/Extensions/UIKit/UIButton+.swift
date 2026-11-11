//
//  UIButton+.swift
//  koin
//
//  Created by 이은지 on 4/29/25.
//

import UIKit

extension UIButton {
    func applyRadioStyle(title: String, font: UIFont, image: UIImage?, foregroundColor: UIColor) {
        var config = UIButton.Configuration.plain()
        var attributedTitle = AttributedString(title)
        attributedTitle.font = font
        config.attributedTitle = attributedTitle
        config.image = image ?? UIImage()
        config.imagePadding = 8
        config.baseForegroundColor = foregroundColor
        self.configuration = config
    }
}

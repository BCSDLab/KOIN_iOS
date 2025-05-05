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
    
    func applyDropdownStyle(title: String,
                            font: UIFont = UIFont.systemFont(ofSize: 14),
                            titleColor: UIColor = .black,
                            borderColor: UIColor = .lightGray,
                            backgroundColor: UIColor = .white,
                            icon: UIImage? = UIImage(systemName: "chevron.down")) {
        
        var config = UIButton.Configuration.plain()
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 0)

        var attributedTitle = AttributedString(title)
        attributedTitle.font = font
        attributedTitle.foregroundColor = titleColor
        config.attributedTitle = attributedTitle

        self.configuration = config
        self.contentHorizontalAlignment = .leading
        self.tintColor = titleColor
        self.layer.borderWidth = 1.0
        self.layer.borderColor = borderColor.cgColor
        self.backgroundColor = backgroundColor

        if let icon = icon {
            let imageView = UIImageView(image: icon)
            imageView.tintColor = titleColor
            imageView.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(imageView)
            NSLayoutConstraint.activate([
                imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
                imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
            ])
        }
    }
    
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
    
    func applyVerificationButtonStyle(title: String, font: UIFont, cornerRadius: CGFloat) {
        self.setTitle(title, for: .normal)
        self.titleLabel?.font = font
        self.layer.cornerRadius = cornerRadius
    }
}

//
//  UILabel+.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/28/24.
//

import UIKit.UILabel

extension UILabel {
    func setLineHeight(lineHeight: CGFloat, text: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = lineHeight
        
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        self.attributedText = attributedString
    }
    
    // 이미지 + 텍스트 response 라벨
    func setImageText(image: UIImage?, text: String, font: UIFont, textColor: UIColor, imageSize: CGSize = CGSize(width: 16, height: 16), spacing: CGFloat = 4) {
        let attributedString = NSMutableAttributedString(string: "")

        let imageAttachment = NSTextAttachment()
        imageAttachment.image = image
        imageAttachment.bounds = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
        attributedString.append(NSAttributedString(attachment: imageAttachment))

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = spacing

        let textAttributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle,
            .font: font,
            .foregroundColor: textColor
        ]

        let textAttributedString = NSAttributedString(string: text, attributes: textAttributes)
        attributedString.append(textAttributedString)

        self.attributedText = attributedString
    }
}

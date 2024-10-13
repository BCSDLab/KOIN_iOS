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
}

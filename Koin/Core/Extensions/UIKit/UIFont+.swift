//
//  UIFont+.swift
//  Koin
//
//  Created by 김나훈 on 1/16/24.
//

import UIKit.UIFont

extension UIFont {
    static func appFont(_ name: FontAsset, size: Int) -> UIFont {
        let fontSize = CGFloat(size)
        return UIFont(name: name.rawValue, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
}

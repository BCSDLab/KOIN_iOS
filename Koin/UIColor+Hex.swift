//
//  UIColor+Hex.swift
//  koin
//
//  Created by 이은지 on 10/16/25.
//

import UIKit

extension UIColor {
    convenience init(hexCode: String, alpha: CGFloat = 1.0) {
        let hexCode = hexCode.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexCode)
        
        if hexCode.hasPrefix("#") {
            scanner.currentIndex = hexCode.index(after: hexCode.startIndex)
        }
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let red = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let green = CGFloat((rgb >> 8) & 0xFF) / 255.0
        let blue = CGFloat(rgb & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

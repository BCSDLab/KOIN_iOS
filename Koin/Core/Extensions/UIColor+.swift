//
//  UIColor+.swift
//  Koin
//
//  Created by 김나훈 on 1/15/24.
//

import UIKit.UIColor

enum SceneColorAsset {
    case primary100, primary200, primary300, primary400, primary500, primary600, primary700, primary800, primary900
    case sub100, sub200, sub300, sub400, sub500, sub600, sub700, sub800, sub900
    case neutral0, neutral50, neutral100, neutral200, neutral300, neutral400, neutral500, neutral600, neutral700, neutral800
    case danger50, danger100, danger200, danger300, danger400, danger500, danger600, danger700
    case warning50, warning100, warning200, warning300, warning400, warning500, warning600, warning700
    case success50, success100, success200, success300, success400, success500, success600, success700
    case info50, info100, info200, info300, info400, info500, info600, info700
    case bus1, bus2, bus3
    case yellow
    case gray
}

extension UIColor {
    static func appColor(_ name: SceneColorAsset) -> UIColor {
        switch name {
        case .primary100: return UIColor(hexCode: "CFF1F9")
        case .primary200: return UIColor(hexCode: "A2DFF3")
        case .primary300: return UIColor(hexCode: "6DBBDD")
        case .primary400: return UIColor(hexCode: "4590BB")
        case .primary500: return UIColor(hexCode: "175C8E")
        case .primary600: return UIColor(hexCode: "10477A")
        case .primary700: return UIColor(hexCode: "0B3566")
        case .primary800: return UIColor(hexCode: "072552")
        case .primary900: return UIColor(hexCode: "041A44")
            
        case .sub100: return UIColor(hexCode: "FEF2D1")
        case .sub200: return UIColor(hexCode: "FEE1A4")
        case .sub300: return UIColor(hexCode: "FCCC77")
        case .sub400: return UIColor(hexCode: "FAB655")
        case .sub500: return UIColor(hexCode: "F7941E")
        case .sub600: return UIColor(hexCode: "D47415")
        case .sub700: return UIColor(hexCode: "B1580F")
        case .sub800: return UIColor(hexCode: "8F3F09")
        case .sub900: return UIColor(hexCode: "762E05")
            
        case .neutral0: return UIColor(hexCode: "FFFFFF")
        case .neutral50: return UIColor(hexCode: "FAFAFA")
        case .neutral100: return UIColor(hexCode: "F5F5F5")
        case .neutral200: return UIColor(hexCode: "EEEEEE")
        case .neutral300: return UIColor(hexCode: "E1E1E1")
        case .neutral400: return UIColor(hexCode: "CACACA")
        case .neutral500: return UIColor(hexCode: "727272")
        case .neutral600: return UIColor(hexCode: "4B4B4B")
        case .neutral700: return UIColor(hexCode: "1F1F1F")
        case .neutral800: return UIColor(hexCode: "000000")
            
        case .danger50: return UIColor(hexCode: "FFFBFB")
        case .danger100: return UIColor(hexCode: "FEF2F2")
        case .danger200: return UIColor(hexCode: "FFEBEE")
        case .danger300: return UIColor(hexCode: "FFCCD2")
        case .danger400: return UIColor(hexCode: "F49898")
        case .danger500: return UIColor(hexCode: "EB6F70")
        case .danger600: return UIColor(hexCode: "F64C4C")
        case .danger700: return UIColor(hexCode: "EC2D30")
            
        case .warning50: return UIColor(hexCode: "FFFDFA")
        case .warning100: return UIColor(hexCode: "FFF9EE")
        case .warning200: return UIColor(hexCode: "FFF7E1")
        case .warning300: return UIColor(hexCode: "FFEAB3")
        case .warning400: return UIColor(hexCode: "FFDD82")
        case .warning500: return UIColor(hexCode: "FFC62B")
        case .warning600: return UIColor(hexCode: "FFAD0D")
        case .warning700: return UIColor(hexCode: "FE9B0E")
            
        case .success50: return UIColor(hexCode: "FBFEFC")
        case .success100: return UIColor(hexCode: "F2FAF6")
        case .success200: return UIColor(hexCode: "E5F5EC")
        case .success300: return UIColor(hexCode: "C0E5D1")
        case .success400: return UIColor(hexCode: "97D4B4")
        case .success500: return UIColor(hexCode: "6BC497")
        case .success600: return UIColor(hexCode: "47B881")
        case .success700: return UIColor(hexCode: "0C9D61")
            
        case .info50: return UIColor(hexCode: "F8FCFF")
        case .info100: return UIColor(hexCode: "F1F8FF")
        case .info200: return UIColor(hexCode: "E4F2FF")
        case .info300: return UIColor(hexCode: "BDDDFF")
        case .info400: return UIColor(hexCode: "93C8FF")
        case .info500: return UIColor(hexCode: "4BA1FF")
        case .info600: return UIColor(hexCode: "3B82F6")
        case .info700: return UIColor(hexCode: "3A70E2")
            
        case .bus1: return UIColor(hexCode: "F7941E")
        case .bus2: return UIColor(hexCode: "7C9FAE")
        case .bus3: return UIColor(hexCode: "4DB297")
        case .yellow: return UIColor(hexCode: "#F4CE83")
        case .gray: return UIColor(hexCode: "8E8E8E")
        }
    }
    static func randomLightColor() -> UIColor {
        let hue = CGFloat(arc4random() % 256) / 256
        let saturation = CGFloat(arc4random() % 77) / 256
        let brightness = CGFloat(arc4random() % 51) / 256 + 0.8
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }
    
}

extension UIColor {
    convenience init(hexCode: String, alpha: CGFloat = 1.0) {
        let scanner = Scanner(string: hexCode)
        _ = scanner.scanString("#")
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double((rgb >> 0) & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

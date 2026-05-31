//
//  UIColor+.swift
//  Koin
//
//  Created by 김나훈 on 1/15/24.
//

import UIKit.UIColor

extension UIColor {
    static func setColor(_ hexCode: String) -> UIColor {
        return UIColor(hexCode: hexCode)
    }

    static func timetableColor(_name: TimetableColorAsset) -> UIColor {
        return UIColor(hexCode: _name.hex)
    }

    static func appColor(_ name: ColorAsset) -> UIColor {
        return UIColor(hexCode: name.hex)
    }
    
    static func randomLightColor() -> UIColor {
        let hue = CGFloat(arc4random() % 256) / 256
        let saturation = CGFloat(arc4random() % 77) / 256
        let brightness = CGFloat(arc4random() % 51) / 256 + 0.8
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }
}

//
//  Color+.swift
//  Koin
//
//  Created by 홍기정 on 5/31/26.
//

import SwiftUI

extension Color {
    static func appColor(_ name: ColorAsset) -> Color {
        Color(hex: name.hex)
    }

    static func timetableColor(_ name: TimetableColorAsset) -> Color {
        Color(hex: name.hex)
    }

    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")

        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >>  8) & 0xFF) / 255.0
        let b = Double((rgb >>  0) & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

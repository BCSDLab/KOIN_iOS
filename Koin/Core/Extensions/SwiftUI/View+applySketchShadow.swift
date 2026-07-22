//
//  View+applySketchShadow.swift
//  Koin
//
//  Created by 홍기정 on 6/2/26.
//

import SwiftUI

extension View {
    func applySketchShadow(color: Color, alpha: Double, x: CGFloat, y: CGFloat, blur: CGFloat) -> some View {
        shadow(color: color.opacity(alpha), radius: blur, x: x, y: y)
    }
}

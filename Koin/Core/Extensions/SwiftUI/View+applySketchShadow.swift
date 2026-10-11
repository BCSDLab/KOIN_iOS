//
//  View+applySketchShadow.swift
//  Koin
//
//  Created by 홍기정 on 6/2/26.
//

import SwiftUI

private struct ApplySketchShadowModifier: ViewModifier {
    let color: Color
    let alpha: Double
    let x: CGFloat
    let y: CGFloat
    let blur: CGFloat

    func body(content: Content) -> some View {
        content.shadow(
            color: color.opacity(alpha),
            radius: blur,
            x: x,
            y: y
        )
    }
}

extension View {
    func applySketchShadow(
        color: Color,
        alpha: Double,
        x: CGFloat,
        y: CGFloat,
        blur: CGFloat
    ) -> some View {
        modifier(ApplySketchShadowModifier(
            color: color,
            alpha: alpha,
            x: x,
            y: y,
            blur: blur
        ))
    }
}

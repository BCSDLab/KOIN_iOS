//
//  View+border.swift
//  koin
//
//  Created by 홍기정 on 6/3/26.
//

import SwiftUI

private struct BorderModifier: ViewModifier {
    let color: Color
    let width: CGFloat
    let radius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .overlay {
                RoundedRectangle(cornerRadius: radius)
                    .stroke(color, lineWidth: width)
            }
    }
}

extension View {
    public func border(
        _ color: Color,
        width: CGFloat,
        radius: CGFloat
    ) -> some View {
        modifier(BorderModifier(color: color, width: width, radius: radius))
    }
}

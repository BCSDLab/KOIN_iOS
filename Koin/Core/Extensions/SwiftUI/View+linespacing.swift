//
//  View+linespacing.swift
//  koin
//
//  Created by 홍기정 on 6/3/26.
//

import SwiftUI

private struct LinespacingModifier: ViewModifier {
    let fontSize: CGFloat
    let percent: CGFloat
    
    func body(content: Content) -> some View {
        let lineheight = fontSize * (percent/100)
        let spacing = lineheight - fontSize
        
        content
            .lineSpacing(spacing)
    }
}

extension View {
    func linespacing(
        fontSize: CGFloat,
        percent: CGFloat
    ) -> some View {
        modifier(LinespacingModifier(
            fontSize: fontSize,
            percent: percent
        ))
    }
}

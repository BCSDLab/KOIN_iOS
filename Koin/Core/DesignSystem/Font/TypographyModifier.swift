//
//  TypographyModifier.swift
//  koin
//
//  Created by 홍기정 on 5/31/26.
//

import UIKit
import SwiftUI

extension View {
    func Typography(_ style: Typography) -> some View {
        self.modifier(TypographyModifier(style: style))
    }
}

struct TypographyModifier: ViewModifier {
    let style: Typography

    func body(content: Content) -> some View {
        content
            .font(style.swiftUIFont)
            .lineSpacing(style.lineSpacing)
    }
}

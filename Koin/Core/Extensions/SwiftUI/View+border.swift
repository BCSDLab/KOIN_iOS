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

private struct EdgeBorder: Shape {
    var borderWidth: CGFloat
    var edges: Set<Edge>
    
    init(width borderWidth: CGFloat, edges: Set<Edge>) {
        self.borderWidth = borderWidth
        self.edges = edges
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        for edge in edges {
            var x: CGFloat
            var y: CGFloat
            var width: CGFloat
            var height: CGFloat
            
            switch edge {
            case .top:
                x = 0
                y = 0
                width = rect.width
                height = borderWidth
            case .bottom:
                x = 0
                y = rect.height - borderWidth
                width = rect.width
                height = borderWidth
            case .leading:
                x = 0
                y = 0
                width = borderWidth
                height = rect.height
            case .trailing:
                x = rect.width - borderWidth
                y = 0
                width = borderWidth
                height = rect.height
            }
            path.addRect(CGRect(x: x, y: y, width: width, height: height))
        }
        return path
    }
}

extension View {
    public func border(
        _ color: Color,
        width: CGFloat,
        radius: CGFloat = 0
    ) -> some View {
        modifier(BorderModifier(color: color, width: width, radius: radius))
    }
    
    public func border(
        _ color: Color,
        width: CGFloat,
        edges: Set<Edge>
    ) -> some View {
        self
            .overlay(
                EdgeBorder(
                    width: width,
                    edges: edges
                )
            .fill(color)
        )
    }
}

//
//  View+isHidden.swift
//  Koin
//
//  Created by 홍기정 on 6/2/26.
//

import SwiftUI

private struct HiddenModifier: ViewModifier {
    let isHidden: Bool
    let shouldOccupySpace: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        if isHidden {
            if shouldOccupySpace {
                content.hidden()
            } else {
                EmptyView()
            }
        } else {
            content
        }
    }
}

extension View {
    func isHidden(_ isHidden: Bool, shouldOccupySpace: Bool = false) -> some View {
        modifier(HiddenModifier(isHidden: isHidden, shouldOccupySpace: shouldOccupySpace))
    }
}

//
//  View+emptyOverlay.swift
//  Koin
//
//  Created by 홍기정 on 6/3/26.
//

import SwiftUI

private struct EmptyOverlayModifier<OverlayContent: View>: ViewModifier {
    let isEmpty: Bool
    let emptyView: () -> OverlayContent

    func body(content: Content) -> some View {
        content.overlay {
            if isEmpty {
                emptyView()
            }
        }
    }
}

extension View {
    func emptyOverlay<OverlayContent: View>(
        _ isEmpty: Bool,
        @ViewBuilder emptyView: @escaping () -> OverlayContent
    ) -> some View {
        modifier(EmptyOverlayModifier(isEmpty: isEmpty, emptyView: emptyView))
    }
}

//
//  View+onFirstAppear.swift
//  Koin
//
//  Created by 홍기정 on 6/2/26.
//

import SwiftUI

private struct OnFirstAppearModifier: ViewModifier {
    let perform: () -> Void

    @State private var hasAppeared = false

    func body(content: Content) -> some View {
        content.onAppear {
            guard !hasAppeared else { return }
            hasAppeared = true
            perform()
        }
    }
}

extension View {
    func onFirstAppear(_ perform: @escaping () -> Void) -> some View {
        modifier(OnFirstAppearModifier(perform: perform))
    }
}

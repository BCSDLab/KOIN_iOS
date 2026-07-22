//
//  View+hideKeyboardWhenTapAround.swift
//  Koin
//
//  Created by 홍기정 on 6/2/26.
//

import SwiftUI
import UIKit

private struct HideKeyboardWhenTapAroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .simultaneousGesture(
                TapGesture().onEnded {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil,
                        from: nil,
                        for: nil
                    )
                }
            )
    }
}

extension View {
    func hideKeyboardWhenTapAround() -> some View {
        modifier(HideKeyboardWhenTapAroundModifier())
    }
}

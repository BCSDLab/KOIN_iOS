//
//  RecruitDataButton.swift
//  koin
//

import SwiftUI

struct RecruitDataButton: View {
    let text: String
    let isEnabled: Bool
    let action: () -> Void
    
    init(
        text: String,
        isEnabled: Bool,
        action: @escaping () -> Void
    ) {
        self.text = text
        self.isEnabled = isEnabled
        self.action = action
    }
    
    private var backgroundColor: Color {
        return isEnabled ? .appColor(.new500) : .appColor(.neutral400)
    }

    var body: some View {
        Button {
            action()
        } label: {
            Text(text)
                .font(.appFont(.pretendardSemiBold, size: 15))
                .foregroundStyle(Color.appColor(.neutral0))
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(backgroundColor, in: RoundedRectangle(cornerRadius: 16))
                .applySketchShadow(
                    color: .appColor(.neutral800),
                    alpha: 0.04,
                    x: 0,
                    y: 2,
                    blur: 4
                )
                .shadow(color: .black.opacity(0.04), radius: 2, y: 2)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}

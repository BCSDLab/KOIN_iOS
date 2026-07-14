//
//  DiningIndicatorChip.swift
//  koin
//
//  Created by 홍기정 on 6/2/26.
//

import SwiftUI

struct DiningIndicatorChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.appFont(.pretendardSemiBold, size: 13))
                .foregroundStyle(isSelected ? Color.ColorSystem.Neutral.gray0 : Color.ColorSystem.Neutral.gray600)
                .padding(.horizontal, 14)
                .padding(.top, 7)
                .padding(.bottom, 8)
                .background(isSelected ? Color.ColorSystem.Primary.purple700 : Color.ColorSystem.Neutral.gray0)
                .clipShape(.capsule)
                .overlay {
                    if !isSelected {
                        Capsule()
                            .stroke(Color.ColorSystem.Neutral.gray300, lineWidth: 0.5)
                    }
                }
        }
        .buttonStyle(.plain)
    }
}

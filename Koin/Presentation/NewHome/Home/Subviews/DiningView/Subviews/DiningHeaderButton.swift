//
//  DiningHeaderButton.swift
//  koin
//
//  Created by 홍기정 on 6/2/26.
//

import SwiftUI

struct DiningHeaderButton: View {
    let onTapAll: () -> Void

    var body: some View {
        HStack {
            Text("오늘의 식단")
                .font(.appFont(.pretendardSemiBold, size: 18))
                .foregroundStyle(Color.ColorSystem.Neutral.gray800)

            Spacer()

            Button(action: onTapAll) {
                HStack(spacing: 0) {
                    Text("전체보기")
                        .Typography(.captionStrong)

                    Image.appImage(asset: .chevronRightRounded)
                        .renderingMode(.template)
                        .frame(width: 16, height: 16)
                }
                .foregroundStyle(Color.ColorSystem.Neutral.gray600)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
    }
}

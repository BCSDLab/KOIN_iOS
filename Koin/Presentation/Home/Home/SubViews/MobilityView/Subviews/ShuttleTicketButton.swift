//
//  ShuttleTicketButton.swift
//  koin
//
//  Created by 홍기정 on 6/1/26.
//

import SwiftUI

struct ShuttleTicketButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text("셔틀 탑승권")
                        .font(.appFont(.pretendardSemiBold, size: 13))
                        .foregroundStyle(Color.ColorSystem.Neutral.gray800)
                        .frame(height: 20.8, alignment: .leading)

                    Text("QR 조회")
                        .font(.appFont(.pretendardSemiBold, size: 12))
                        .foregroundStyle(Color.ColorSystem.Neutral.gray600)
                        .frame(height: 19.2, alignment: .leading)
                }
                .frame(width: 60, height: 40, alignment: .leading)

                Spacer(minLength: 0)

                Image.appImage(asset: .homeQR)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(Color.ColorSystem.Primary.purple700)
                    .frame(width: 40, height: 40)
            }
            .padding(12)
            .frame(width: 150, height: 64)
            .background(Color.ColorSystem.Neutral.gray0)
            .clipShape(.rect(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

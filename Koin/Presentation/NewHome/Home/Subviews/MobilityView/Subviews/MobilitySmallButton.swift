//
//  MobilitySmallButton.swift
//  koin
//
//  Created by 홍기정 on 6/1/26.
//

import SwiftUI

struct MobilitySmallButton: View {
    let imageAsset: ImageAsset
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                Image.appImage(asset: imageAsset)
                    .renderingMode(.original)
                    .frame(width: 40, height: 40)
                    .background(Color.ColorSystem.Neutral.gray100)
                    .clipShape(.rect(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .font(.appFont(.pretendardSemiBold, size: 15))
                        .foregroundStyle(Color(hex: "0B0B0D"))
                        .frame(height: 24, alignment: .leading)

                    Text(subtitle)
                        .font(.appFont(.pretendardRegular, size: 12))
                        .foregroundStyle(Color.ColorSystem.Neutral.gray500)
                        .frame(height: 19, alignment: .leading)
                }

                Text("조회하기 →")
                    .font(.appFont(.pretendardRegular, size: 10))
                    .foregroundStyle(Color.ColorSystem.Primary.purple700)
                    .frame(height: 16, alignment: .leading)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.ColorSystem.Neutral.gray0)
            .clipShape(.rect(cornerRadius: 16))
            .border(Color.ColorSystem.Neutral.gray300, width: 0.5, radius: 16)
        }
        .buttonStyle(.plain)
    }
}

//
//  HeaderView.swift
//  koin
//
//  Created by 홍기정 on 6/1/26.
//

import SwiftUI

struct HomeHeaderView: View {
    private let header: HomeHeader

    init(header: HomeHeader) {
        self.header = header
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 4) {
                Text(verbatim: header.dateText)
                    .Typography(.caption)
                    .foregroundStyle(Color.ColorSystem.Primary.purple700)

                Image.appImage(asset: header.weatherImage)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundStyle(Color.ColorSystem.Primary.purple800)

                Text(verbatim: " \(header.weatherText)")
                    .Typography(.caption)
                    .foregroundStyle(Color.ColorSystem.Neutral.gray600)
            }

            VStack(alignment: .leading, spacing: 0) {
                Text(verbatim: "\(header.userName)님,")
                    .font(.appFont(.pretendardBold, size: 24))
                    .foregroundStyle(Color(hex: "0B0B0D"))

                Text(verbatim: header.message)
                    .font(.appFont(.pretendardBold, size: 24))
                    .foregroundStyle(Color(hex: "0B0B0D"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.top, 16)
        .padding(.horizontal, 24)
        .padding(.bottom, 0)
        .frame(maxWidth: .infinity, minHeight: 98, alignment: .topLeading)
    }
}

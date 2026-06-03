//
//  CallVanRecruitmentButton.swift
//  koin
//
//  Created by 홍기정 on 6/1/26.
//

import SwiftUI

struct CallVanRecruitmentButton: View {
    let recruitingCount: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image.appImage(asset: .homeCallVan)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .frame(width: 40, height: 40)
                    .background(Color.ColorSystem.Primary.purple700)
                    .clipShape(.rect(cornerRadius: 8))


                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 8) {
                        Text("콜밴팟")
                            .font(.appFont(.pretendardSemiBold, size: 15))
                            .foregroundStyle(Color.ColorSystem.Neutral.gray0)

                        Text("\(recruitingCount)건 모집중")
                            .font(.appFont(.pretendardMedium, size: 10))
                            .foregroundStyle(Color.ColorSystem.Primary.purple800)
                            .frame(height: 16)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 1)
                            .background(Color.ColorSystem.Neutral.gray50)
                            .clipShape(.capsule)
                            .isHidden(recruitingCount == 0)
                    }
                    .frame(height:24)

                    Text("같이 콜벤 탈 사람을 찾아요")
                        .font(.appFont(.pretendardRegular, size: 12))
                        .foregroundStyle(Color.ColorSystem.Neutral.gray500)
                        .frame(height: 19)
                }

                Spacer()

                Text("모집 보기")
                    .font(.appFont(.pretendardSemiBold, size: 13))
                    .foregroundStyle(Color.ColorSystem.Neutral.gray50)
                    .frame(height: 21)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.ColorSystem.Primary.purple700)
                    .clipShape(.rect(cornerRadius: 10))

            }
            .padding(20)
            .frame(maxWidth: .infinity, minHeight: 83, maxHeight: 83)
            .background(Color.ColorSystem.Neutral.gray900)
            .clipShape(.rect(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.ColorSystem.Neutral.gray300, lineWidth: 0.5)
            }
        }
        .buttonStyle(.plain)
    }
}

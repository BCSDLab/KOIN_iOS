//
//  ShopView.swift
//  koin
//
//  Created by 홍기정 on 6/1/26.
//

import SwiftUI

struct ShopView: View {
    private let eventCount: Int
    private let openShopCount: Int
    private let totalShopCount: Int
    private let onTapAll: () -> Void
    private let onTapShopCard: () -> Void

    init(
        eventCount: Int,
        openShopCount: Int,
        totalShopCount: Int,
        onTapAll: @escaping () -> Void,
        onTapShopCard: @escaping () -> Void
    ) {
        self.eventCount = eventCount
        self.openShopCount = openShopCount
        self.totalShopCount = totalShopCount
        self.onTapAll = onTapAll
        self.onTapShopCard = onTapShopCard
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack() {
                Text("주변 상점")
                    .font(.appFont(.pretendardSemiBold, size: 18))
                    .foregroundStyle(Color.ColorSystem.Neutral.gray800)

                Spacer()

                Button(action: onTapAll) {
                    HStack(spacing: 0) {
                        Text("전체보기")
                            .font(.appFont(.pretendardMedium, size: 13))
                            .foregroundStyle(Color.ColorSystem.Neutral.gray600)

                        Image.appImage(asset: .chevronRightRounded)
                            .frame(width: 16, height: 16)
                    }
                }
                .buttonStyle(.plain)
            }
            .frame(height: 29, alignment: .center)

            Button(action: onTapShopCard) {

                HStack(spacing: 20) {
                    Image.appImage(asset: .homeShop)
                        .frame(width: 40, height: 40)
                        .background(Color.ColorSystem.Neutral.gray100)
                        .clipShape(.rect(cornerRadius: 10))

                    VStack(alignment: .leading) {
                        Text("KOIN 전용 이벤트 \(eventCount)곳")
                            .font(.appFont(.pretendardMedium, size: 10))
                            .foregroundStyle(Color.ColorSystem.Primary.purple800)
                            .frame(height: 16)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 1)
                            .background(Color.ColorSystem.Primary.purple100)
                            .clipShape(.capsule)
                            .padding(.bottom, 8)
                            .isHidden(!(0<eventCount))

                        Text("많이 찾는 상점\n둘러보기")
                            .font(.appFont(.pretendardSemiBold, size: 16))
                            .linespacing(fontSize: 16, percent: 160)
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(Color.ColorSystem.Neutral.gray900)

                        HStack(spacing: 2) {
                            Text("영업중")
                                .font(.appFont(.pretendardRegular, size: 13))
                                .foregroundStyle(Color.ColorSystem.Neutral.gray500)

                            Text("\(openShopCount)곳")
                                .font(.appFont(.pretendardSemiBold, size: 13))
                                .foregroundStyle(Color.ColorSystem.Primary.purple700)

                            Text("|")
                                .font(.appFont(.pretendardRegular, size: 13))
                                .foregroundStyle(Color.ColorSystem.Neutral.gray500)

                            Text("전체")
                                .font(.appFont(.pretendardRegular, size: 13))
                                .foregroundStyle(Color.ColorSystem.Neutral.gray500)

                            Text("\(totalShopCount)곳")
                                .font(.appFont(.pretendardRegular, size: 13))
                                .foregroundStyle(Color.ColorSystem.Neutral.gray500)
                        }
                        .frame(height: 21)
                    }
                }

                Spacer()

                Image.appImage(asset: .chevronRightRounded)
                    .frame(width: 57, height: 20)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(Color.ColorSystem.Neutral.gray0)
            .clipShape(.rect(cornerRadius: 16))
            .border(Color.ColorSystem.Neutral.gray300, width: 0.5, radius: 16)
            .buttonStyle(.plain)
        }
        .padding(.top, 16)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
    }
}

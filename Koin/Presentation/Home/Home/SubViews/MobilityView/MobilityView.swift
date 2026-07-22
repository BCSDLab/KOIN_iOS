//
//  MobilityView.swift
//  koin
//
//  Created by 홍기정 on 6/1/26.
//

import SwiftUI

struct MobilityView: View {
    private let callVanRecruitingCount: Int
    private let onTapShuttleTicket: () -> Void
    private let onTapCallVan: () -> Void
    private let onTapBusTimetable: () -> Void
    private let onTapBusRoute: () -> Void

    init(
        callVanRecruitingCount: Int,
        onTapShuttleTicket: @escaping () -> Void,
        onTapCallVan: @escaping () -> Void,
        onTapBusTimetable: @escaping () -> Void,
        onTapBusRoute: @escaping () -> Void
    ) {
        self.callVanRecruitingCount = callVanRecruitingCount
        self.onTapShuttleTicket = onTapShuttleTicket
        self.onTapCallVan = onTapCallVan
        self.onTapBusTimetable = onTapBusTimetable
        self.onTapBusRoute = onTapBusRoute
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center) {
                Text("교통")
                    .font(.appFont(.pretendardSemiBold, size: 18))
                    .foregroundStyle(Color.ColorSystem.Neutral.gray800)

                Spacer()

                ShuttleTicketButton(action: onTapShuttleTicket)
            }
            .frame(height: 64)

            CallVanRecruitmentButton(
                recruitingCount: callVanRecruitingCount,
                action: onTapCallVan
            )

            HStack(spacing: 12) {
                MobilitySmallButton(
                    imageAsset: .categoryBusTimetable,
                    title: "버스 시간표",
                    subtitle: "노선 별 출발 시간",
                    action: onTapBusTimetable
                )
                MobilitySmallButton(
                    imageAsset: .categoryBusSearch,
                    title: "버스 노선 조회",
                    subtitle: "가장 빠른 버스 찾기",
                    action: onTapBusRoute
                )
            }
        }
        .padding(.top, 16)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

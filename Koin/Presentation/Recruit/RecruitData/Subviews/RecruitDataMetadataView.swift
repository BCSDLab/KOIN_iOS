//
//  RecruitDataMetadataView.swift
//  koin
//

import SwiftUI

struct RecruitDataMetadataView: View {
    let data: RecruitData

    var body: some View {
        Grid(horizontalSpacing: 12, verticalSpacing: 12) {
            metadataRow(
                icon: .recruitDataLocation,
                title: "진행 방식",
                value: data.meetingType.rawValue
            )
            metadataRow(
                icon: .recruitDataCalendar,
                title: "활동 기간",
                value: "\(data.startDate) ~ \(data.endDate)"
            )
            metadataRow(
                icon: .recruitDataMembers,
                title: "모집 인원",
                value: "\(data.currentParticipants)/\(data.maximumParticipants)명"
            )
            metadataRow(
                icon: .recruitDataClock,
                title: "작성일",
                value: data.createdAt ?? "-"
            )
            metadataRow(
                icon: .recruitDataAuthor,
                title: "작성자",
                value: data.author ?? "-"
            )
        }
    }
}

extension RecruitDataMetadataView {
    private func metadataRow(
        icon asset: ImageAsset,
        title: String,
        value: String
    ) -> some View {
        GridRow {
            HStack(spacing: 4) {
                Image.appImage(asset: asset)
                Text(title)
                    .font(.appFont(.pretendardMedium, size: 12))
                    .foregroundStyle(Color.appColor(.neutral800))
            }
            .frame(maxWidth: .infinity, minHeight: 19, alignment: .leading)
            
            Text(value)
                .font(.appFont(.pretendardRegular, size: 12))
                .frame(maxWidth: .infinity, idealHeight: 19, alignment: .center)
        }
    }
}

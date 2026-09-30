//
//  RecruitMyPostApplicantActivityView.swift
//  koin
//
//  Created by 홍기정 on 9/28/26.
//

import SwiftUI

struct RecruitMyPostApplicantActivityView: View {

    let activity: RecruitProfileActivity

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(activity.title)
                .font(.appFont(.pretendardSemiBold, size: 14))
                .foregroundStyle(Color.appColor(.neutral800))
                .frame(minHeight: 22)

            activityRow(title: "활동 기간", content: activity.periodText)
            activityRow(title: "활동 내용", content: activity.description)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.appColor(.neutral0))
        .clipShape(.rect(cornerRadius: 16))
    }
}

extension RecruitMyPostApplicantActivityView {
    private func activityRow(title: String, content: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(title)
                .font(.appFont(.pretendardRegular, size: 12))
                .foregroundStyle(Color.appColor(.neutral500))
                .frame(minHeight: 19)
            Text(content)
                .font(.appFont(.pretendardRegular, size: 12))
                .linespacing(fontSize: 12, percent: 160)
                .foregroundStyle(Color.appColor(.neutral800))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.appFont(.pretendardRegular, size: 12))
    }
}

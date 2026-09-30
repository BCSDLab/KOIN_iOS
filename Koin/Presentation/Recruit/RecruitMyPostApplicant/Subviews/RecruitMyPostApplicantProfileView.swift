//
//  RecruitMyPostApplicantProfileView.swift
//  koin
//
//  Created by 홍기정 on 9/28/26.
//

import SwiftUI

struct RecruitMyPostApplicantProfileView: View {

    let application: RecruitApplication

    var body: some View {
        HStack(spacing: 12) {
            Image.appImage(asset: .recruitNotificationMember)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
                .frame(width: 45, height: 45)
                .border(Color.appColor(.neutral300), width: 1, radius: 50/2)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(application.profile.nickname)
                        .font(.appFont(.pretendardRegular, size: 14))
                        .foregroundStyle(Color.appColor(.neutral800))

                    Spacer(minLength: 8)

                    Text(application.status.rawValue)
                        .font(.appFont(.pretendardMedium, size: 11))
                        .foregroundStyle(Color.appColor(application.status.textColor))
                }

                applicantMetadata
                    .font(.appFont(.pretendardRegular, size: 11))
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(Color.appColor(.neutral0))
        .clipShape(.rect(cornerRadius: 16))
        .accessibilityElement(children: .combine)
    }
}

extension RecruitMyPostApplicantProfileView {
    @ViewBuilder
    private var applicantMetadata: some View {
        let profile = application.profile
        let studentYear = String(profile.studentNumber.prefix(4).suffix(2))

        if let role = application.role, !role.isEmpty {
            HStack(spacing: 0) {
                Text(role)
                    .foregroundStyle(Color.appColor(.new500))
                Text(" |  \(profile.department) · \(studentYear)학번")
                    .foregroundStyle(Color.appColor(.neutral500))
            }
        } else {
            Text("\(profile.department) · \(studentYear)학번")
                .foregroundStyle(Color.appColor(.neutral500))
        }
    }
}

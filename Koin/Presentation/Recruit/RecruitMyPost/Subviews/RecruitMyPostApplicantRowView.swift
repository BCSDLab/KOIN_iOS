//
//  RecruitMyPostApplicantRowView.swift
//  koin
//
//  Created by 홍기정 on 9/27/26.
//

import SwiftUI

struct RecruitMyPostApplicantRowView: View {

    let onApplicationTapped: ()->Void
    let onDirectChatTapped: ()->Void
    let model: RecruitApplication
    
    init(
        model: RecruitApplication,
        onApplicationTapped: @escaping () -> Void,
        onDirectChatTapped: @escaping () -> Void
    ) {
        self.onApplicationTapped = onApplicationTapped
        self.onDirectChatTapped = onDirectChatTapped
        self.model = model
    }

    var body: some View {
        Button(action: onApplicationTapped) {
            HStack(spacing: 12) {
                profileImage
                applicantInformation
                Spacer(minLength: 0)
                Image.appImage(asset: .newChevronRight)
                    .frame(width: 24, height: 24)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(Color.appColor(.neutral0))
            .clipShape(.rect(cornerRadius: 16))
            .contentShape(.rect(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

extension RecruitMyPostApplicantRowView {
    private var profileImage: some View {
        Image.appImage(asset: .recruitNotificationMember)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 30, height: 30)
            .frame(width: 45, height: 45)
            .border(Color.appColor(.neutral400), width: 1, radius: 45/2)
    }

    private var applicantInformation: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Text(model.nickname)
                    .font(.appFont(.pretendardRegular, size: 14))
                    .foregroundStyle(Color.appColor(.neutral800))

                Text("· \(model.status.rawValue)")
                    .font(.appFont(.pretendardMedium, size: 11))
                    .foregroundStyle(Color.appColor(model.status.textColor))

                if model.status == .accepted, model.canChat {
                    Button(action: onDirectChatTapped) {
                        Image.appImage(asset: .recruitNotificationChat)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(height: 24)

            applicantMetadata
                .font(.appFont(.pretendardRegular, size: 11))
                .lineLimit(1)
        }
    }

    @ViewBuilder
    private var applicantMetadata: some View {
        if !model.role.isEmpty {
            HStack(spacing: 0) {
                Text(model.role)
                    .foregroundStyle(Color.appColor(.new500))
                Text(" |  \(model.department) · \(model.studentYear)학번")
                    .foregroundStyle(Color.appColor(.neutral500))
            }
        } else {
            Text("\(model.department) · \(model.studentYear)학번")
                .foregroundStyle(Color.appColor(.neutral500))
        }
    }
}

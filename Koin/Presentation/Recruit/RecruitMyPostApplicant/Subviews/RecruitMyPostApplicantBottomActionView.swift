//
//  RecruitMyPostApplicantBottomActionView.swift
//  koin
//
//  Created by 홍기정 on 9/28/26.
//

import SwiftUI

struct RecruitMyPostApplicantBottomActionView: View {

    let application: RecruitApplication
    let isLoading: Bool
    let onDecisionTapped: (RecruitApplicationDecision) -> Void
    let onDirectChatTapped: () -> Void

    @ViewBuilder
    var body: some View {
        if application.canDecide {
            HStack(spacing: 12) {
                decisionButton(
                    title: "거절하기",
                    foregroundColor: .new500,
                    backgroundColor: .neutral0,
                    borderColor: .new500
                ) {
                    onDecisionTapped(.denied)
                }

                decisionButton(
                    title: "승인하기",
                    foregroundColor: .neutral0,
                    backgroundColor: .new500,
                    borderColor: .new500
                ) {
                    onDecisionTapped(.accepted)
                }
            }
        } else if application.status == .accepted {
            HStack(spacing: 12) {
                statusButton(title: "승인된 지원자", color: .new500)

                if application.canDirectChat {
                    Button(action: onDirectChatTapped) {
                        Image.appImage(asset: .recruitNotificationChat)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .frame(width: 50, height: 50)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("지원자와 채팅하기")
                }
            }
        } else if application.status == .denied {
            statusButton(title: "거절된 지원자", color: .danger700)
        }
    }
}

extension RecruitMyPostApplicantBottomActionView {
    private func decisionButton(
        title: String,
        foregroundColor: ColorAsset,
        backgroundColor: ColorAsset,
        borderColor: ColorAsset,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.appFont(.pretendardSemiBold, size: 15))
                .foregroundStyle(Color.appColor(foregroundColor))
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.appColor(backgroundColor))
                .clipShape(.rect(cornerRadius: 16))
                .border(Color.appColor(borderColor), width: 0.5, radius: 16)
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
    }

    private func statusButton(title: String, color: ColorAsset) -> some View {
        Text(title)
            .font(.appFont(.pretendardSemiBold, size: 15))
            .foregroundStyle(Color.appColor(color))
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(Color.appColor(.neutral0))
            .clipShape(.rect(cornerRadius: 16))
            .border(Color.appColor(color), width: 0.5, radius: 16)
            .accessibilityAddTraits(.isStaticText)
    }
}

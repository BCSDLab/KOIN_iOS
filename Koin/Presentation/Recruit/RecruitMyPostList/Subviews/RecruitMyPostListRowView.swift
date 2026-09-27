//
//  RecruitMyPostListRowView.swift
//  koin
//
//  Created by 홍기정 on 9/24/26.
//

import SwiftUI

struct RecruitMyPostListRowView: View {

    let model: RecruitMyPostSummary
    let onShowDetail: () -> Void
    let onShowChat: (Int) -> Void
    let onShowApplicants: () -> Void
    let onCloseRecruit: () -> Void

    var body: some View {
        Button(action: onShowDetail) {
            VStack(alignment: .leading, spacing: 0) {
                headerView
                    .padding(.bottom, 8)
                titleView
                    .padding(.bottom, 4)
                rolesView
                    .padding(.bottom, 8)
                    .isHidden(model.type == .general)
                dataView
                manageButtons
                    .padding(.top, 8)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.appColor(.neutral0))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

extension RecruitMyPostListRowView {
    private var headerView: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(model.category.rawValue)
                .font(.appFont(.pretendardMedium, size: 10))
                .foregroundStyle(Color.appColor(model.category.foregroundColor))
                .padding(.horizontal, 8)
                .frame(height: 18)
                .background(Color.appColor(model.category.backgroundColor))
                .clipShape(.capsule)

            Text(model.state == .closed ? "모집완료" : model.dDay)
                .font(.appFont(.pretendardMedium, size: 10))
                .foregroundStyle(Color.appColor(model.state == .closed ? .new600 : .danger700))

            Spacer()
        }
        .padding(.trailing, model.chatRoomId == nil ? 0 : 44)
        .overlay(alignment: .trailing) {
            if let chatRoomId = model.chatRoomId {
                Button {
                    onShowChat(chatRoomId)
                } label: {
                    Image.appImage(asset: .recruitNotificationChat)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .frame(width: 36, height: 36)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var titleView: some View {
        Text(model.title)
            .font(.appFont(.pretendardSemiBold, size: 16))
            .foregroundStyle(Color.appColor(.neutral700))
            .frame(height: 26)
            .lineLimit(1)
    }

    private var rolesView: some View {
        LeftAlignedLayout(interitemSpacing: 4, interlineSpacing: 4) {
            ForEach(model.roles) { role in
                Text("\(role.name) \(role.maximumParticipants)")
                    .font(.appFont(.pretendardRegular, size: 10))
                    .foregroundStyle(Color.appColor(.neutral500))
                    .padding(.horizontal, 8)
                    .frame(height: 18)
                    .background(Color.appColor(.neutral200))
                    .clipShape(.capsule)
            }
        }
    }
}

extension RecruitMyPostListRowView {
    private var dataView: some View {
        LeftAlignedLayout(interitemSpacing: 8, interlineSpacing: 4) {
            Group {
                HStack(alignment: .center, spacing: 2) {
                    Image.appImage(asset: .recruitLocation)
                    Text(model.meetingType.rawValue)
                        .font(.appFont(.pretendardRegular, size: 10))
                        .foregroundStyle(Color.appColor(.neutral500))
                }

                HStack(alignment: .center, spacing: 2) {
                    Image.appImage(asset: .recruitDate)
                    Text("\(model.startDate.formatDateToYYYYMMDD(separator: ".")) ~ \(model.endDate.formatDateToYYYYMMDD(separator: "."))")
                        .font(.appFont(.pretendardRegular, size: 10))
                        .foregroundStyle(Color.appColor(.neutral500))
                }

                HStack(alignment: .center, spacing: 2) {
                    Image.appImage(asset: .recruitMember)
                    Text("\(model.currentParticipants)/\(model.maximumParticipants)명")
                        .font(.appFont(.pretendardRegular, size: 10))
                        .foregroundStyle(Color.appColor(.neutral500))
                }
            }
            .frame(height: 16)
        }
    }

    private var manageButtons: some View {
        HStack(spacing: 26) {
            Button(action: onShowApplicants) {
                manageButtonLabel("지원자 관리")
            }
            .buttonStyle(.plain)

            if model.canClose {
                Button(action: onCloseRecruit) {
                    manageButtonLabel("모집 마감")
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func manageButtonLabel(_ title: String) -> some View {
        Text(title)
            .font(.appFont(.pretendardRegular, size: 14))
            .foregroundStyle(Color.appColor(.new500))
            .frame(maxWidth: .infinity, minHeight: 40)
            .border(.appColor(.new500), width: 1, radius: 16)
            .contentShape(RoundedRectangle(cornerRadius: 16))
    }
}

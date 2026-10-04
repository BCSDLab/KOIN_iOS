//
//  RecruitMyPostSummaryView.swift
//  koin
//
//  Created by 홍기정 on 9/27/26.
//

import SwiftUI

struct RecruitMyPostSummaryView: View {

    let model: RecruitMyPostData
    let onGroupChatTapped: ()->Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerView
                .padding(.bottom, 8)
            titleView
                .padding(.bottom, 4)
            rolesView
                .padding(.bottom, 8)
                .isHidden(model.type == .general)
            dataView
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.appColor(.neutral0))
        .clipShape(.rect(cornerRadius: 16))
    }
}

extension RecruitMyPostSummaryView {
    private var headerView: some View {
        HStack(alignment: .center, spacing: 4) {
            Text(model.category.rawValue)
                .font(.appFont(.pretendardMedium, size: 10))
                .foregroundStyle(Color.appColor(model.category.foregroundColor))
                .padding(.horizontal, 8)
                .frame(height: 18)
                .background(Color.appColor(model.category.backgroundColor))
                .clipShape(.capsule)

            if model.state == .closed {
                Text("모집완료")
                    .font(.appFont(.pretendardMedium, size: 10))
                    .foregroundStyle(Color.appColor(.new600))
            } else if let dDay = model.dDay {
                Text(dDay)
                    .font(.appFont(.pretendardMedium, size: 10))
                    .foregroundStyle(Color.appColor(.danger700))
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
                Text("\(role.name) \(role.maximumParticipants)명")
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

extension RecruitMyPostSummaryView {
    private var dataView: some View {
        LeftAlignedLayout(interitemSpacing: 8, interlineSpacing: 4) {
            Group {
                metadataView(
                    image: .recruitLocation,
                    text: model.meetingType.rawValue
                )
                metadataView(
                    image: .recruitDate,
                    text: "\(model.startDate?.formatDateToYYYYMMDD(separator: ".") ?? "") ~ \(model.endDate?.formatDateToYYYYMMDD(separator: ".") ?? "")"
                )
                metadataView(
                    image: .recruitMember,
                    text: "\(model.currentParticipants)/\(model.maximumParticipants)명"
                )
            }
            .frame(height: 16)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.trailing, model.chatRoomId == nil ? 0 : 44)
        .overlay(alignment: .trailing) {
            Button(action: onGroupChatTapped) {
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

    private func metadataView(image: ImageAsset, text: String) -> some View {
        HStack(alignment: .center, spacing: 2) {
            Image.appImage(asset: image)
            Text(text)
                .font(.appFont(.pretendardRegular, size: 10))
                .foregroundStyle(Color.appColor(.neutral500))
        }
    }
}

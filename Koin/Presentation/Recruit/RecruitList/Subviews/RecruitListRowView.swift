//
//  RecruitListRowView.swift
//  koin
//
//  Created by 홍기정 on 8/29/26.
//

import SwiftUI

struct RecruitListRowView: View {
    
    let model: RecruitDetail
    
    init(model: RecruitDetail) {
        self.model = model
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerView
                .padding(.bottom, 8)
            titleLabel
                .padding(.bottom, 4)
            rolesView
                .padding(.bottom, 8)
                .isHidden(model.type == .general)
            detailView
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            Color.appColor(.neutral0)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

extension RecruitListRowView {
    @ViewBuilder
    private var headerView: some View {
        HStack(alignment: .center, spacing: 4) {
            Text(model.category.rawValue)
                .font(.appFont(.pretendardMedium, size: 10))
                .foregroundStyle(Color.appColor(model.category.foregroundColor))
                .padding(.horizontal, 8)
                .frame(height: 18)
                .background(Color.appColor(model.category.backgroundColor))
                .clipShape(.capsule)
            
            Text("D-\(model.dDay)")
                .font(.appFont(.pretendardMedium, size: 10))
                .foregroundStyle(Color.appColor(.danger700))
        }
    }
    
    @ViewBuilder
    private var titleLabel: some View {
        Text(model.title)
            .font(.appFont(.pretendardSemiBold, size: 16))
            .foregroundStyle(Color.appColor(.neutral700))
            .frame(height: 26)
            .lineLimit(1)
    }
    
    @ViewBuilder
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
    
    @ViewBuilder
    private var detailView: some View {
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
                    Text("\(model.startDate) ~ \(model.endDate)")
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
}

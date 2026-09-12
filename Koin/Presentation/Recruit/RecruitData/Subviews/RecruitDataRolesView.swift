//
//  RecruitDataRolesView.swift
//  koin
//

import SwiftUI

struct RecruitDataRolesView: View {
    let roles: [RecruitRole]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("모집 역할 및 인원")
                .font(.appFont(.pretendardSemiBold, size: 14))
                .foregroundStyle(Color.appColor(.neutral700))
                .frame(minHeight: 22)
            
            VStack(spacing: 0) {
                ForEach(roles) { role in
                    roleRow(role)
                        .border(role.id != roles.last?.id ? .appColor(.neutral200) : .clear,
                                width: 1,
                                edges: [.bottom]
                        )
                }
            }
            .border(
                .appColor(.neutral200),
                width: 1,
                radius: 12
            )
        }
    }
}

extension RecruitDataRolesView {
    private func roleRow(_ role: RecruitRole) -> some View {
        return HStack(spacing: 0) {
            HStack(spacing: 4) {
                Image.appImage(asset: role.isClosed ? .recruitDataRoleClosed : .recruitDataRoleOpen)

                Text(role.name)
                    .font(.appFont(.pretendardMedium, size: 12))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(role.isClosed ? "마감" : "\(role.maximumParticipants)명")
                .font(.appFont(.pretendardRegular, size: 12))
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 10)
        .frame(minHeight: 32)
    }
}

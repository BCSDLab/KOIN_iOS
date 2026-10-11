//
//  RecruitMyPostApplicantRoleChipView.swift
//  koin
//
//  Created by 홍기정 on 9/28/26.
//

import SwiftUI

struct RecruitMyPostApplicantRoleChipView: View {

    let role: String

    var body: some View {
        Text(role)
            .font(.appFont(.pretendardRegular, size: 12))
            .foregroundStyle(Color.appColor(.neutral500))
            .padding(.horizontal, 12)
            .frame(minHeight: 36)
            .background(Color.appColor(.neutral0))
            .clipShape(.capsule)
    }
}

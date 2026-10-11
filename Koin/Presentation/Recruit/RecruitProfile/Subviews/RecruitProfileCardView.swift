//
//  RecruitProfileCardView.swift
//  koin
//
//  Created by 홍기정 on 9/13/26.
//

import SwiftUI

struct RecruitProfileCardView: View {
    
    let profile: RecruitProfile
    let action: ()->Void
    
    init(
        profile: RecruitProfile,
        action: @escaping ()->Void
    ) {
        self.profile = profile
        self.action = action
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image.appImage(asset: .profileHuman)
                .frame(width: 40, height: 40, alignment: .center)
                .border(.appColor(.neutral400), width: 1, radius: 20)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(profile.nickname)
                    .font(.appFont(.pretendardSemiBold, size: 16))
                    .foregroundStyle(Color.appColor(.neutral800))
                    .frame(minHeight: 22)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(" • " + profile.department)
                        .font(.appFont(.pretendardRegular, size: 12))
                        .foregroundStyle(Color.appColor(.neutral500))
                        .frame(minHeight: 19)
                    
                    Text(" • " + profile.studentNumber)
                        .font(.appFont(.pretendardRegular, size: 12))
                        .foregroundStyle(Color.appColor(.neutral500))
                        .frame(minHeight: 19)
                }
                
                RecruitProfileActionButton(
                    title: "프로필 수정하기",
                    action: action
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.appColor(.neutral0))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

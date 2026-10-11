//
//  RecruitProfileCardView.swift
//  koin
//
//  Created by 홍기정 on 9/13/26.
//

import SwiftUI

struct RecruitProfileEmptyCardView: View {
    
    let action: ()->Void
    
    init(action: @escaping () -> Void) {
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Image.appImage(asset: .sleepBcsdSymbol)
                .resizable()
                .scaledToFit()
                .frame(width: 85, height: 66)
                .padding(.bottom, 4)
            
            Text("아직 팀원 모집 프로필을 작성하지 않았어요.")
                .font(.appFont(.pretendardSemiBold, size: 16))
                .foregroundStyle(Color.appColor(.neutral800))
                .multilineTextAlignment(.center)
                .frame(minHeight: 26)
                .padding(.bottom, 12)
            
            Text("프로필을 작성하면 지원 시 더 빠르고 편리하게 활동할 수 있어요.")
                .font(.appFont(.pretendardRegular, size: 12))
                .foregroundStyle(Color.appColor(.neutral500))
                .multilineTextAlignment(.center)
                .frame(minHeight: 19)
                .padding(.bottom, 12)
            
            RecruitProfileActionButton(
                title: "프로필 작성하기",
                action: action
            )
        }
        .padding(20)
        .background(Color.appColor(.neutral0))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
